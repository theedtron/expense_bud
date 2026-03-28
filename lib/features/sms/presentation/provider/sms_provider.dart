import 'package:expense_bud/core/domain/entities/expense.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/expense/domain/usecases/create_entry_usecase.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';
import 'package:expense_bud/features/sms/domain/usecases/get_business_by_name_usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/get_businesses_usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/get_mpesa_sms_usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/get_persons_usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/request_sms_permission_usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/save_business_usecase.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/features/sms/domain/usecases/save_person_usecase.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum SmsProviderState { initial, loading, loaded, error }

class SmsProvider extends ChangeNotifier {
  final GetMpesaSmsUsecase _getMpesaSmsUsecase;
  final RequestSmsPermissionUsecase _requestSmsPermissionUsecase;
  final CreateExpenseEntryUsecase _createExpenseEntryUsecase;
  final GetBusinessesUsecase _getBusinessesUsecase;
  final GetBusinessByNameUsecase _getBusinessByNameUsecase;
  final SaveBusinessUsecase _saveBusinessUsecase;
  final GetPersonsUsecase _getPersonsUsecase;
  final SavePersonUsecase _savePersonUsecase;
  final Uuid _uuid = const Uuid();

  SmsProvider({
    required GetMpesaSmsUsecase getMpesaSmsUsecase,
    required RequestSmsPermissionUsecase requestSmsPermissionUsecase,
    required CreateExpenseEntryUsecase createExpenseEntryUsecase,
    required GetBusinessesUsecase getBusinessesUsecase,
    required GetBusinessByNameUsecase getBusinessByNameUsecase,
    required SaveBusinessUsecase saveBusinessUsecase,
    required GetPersonsUsecase getPersonsUsecase,
    required SavePersonUsecase savePersonUsecase,
  })  : _getMpesaSmsUsecase = getMpesaSmsUsecase,
        _requestSmsPermissionUsecase = requestSmsPermissionUsecase,
        _createExpenseEntryUsecase = createExpenseEntryUsecase,
        _getBusinessesUsecase = getBusinessesUsecase,
        _getBusinessByNameUsecase = getBusinessByNameUsecase,
        _saveBusinessUsecase = saveBusinessUsecase,
        _getPersonsUsecase = getPersonsUsecase,
        _savePersonUsecase = savePersonUsecase;

  SmsProviderState _state = SmsProviderState.initial;
  SmsProviderState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<SmsMessageModel> _mpesaSms = [];
  List<SmsMessageModel> get mpesaSms => _mpesaSms;

  List<BusinessModel> _businesses = [];
  List<BusinessModel> get businesses => _businesses;

  List<PersonModel> _persons = [];
  List<PersonModel> get persons => _persons;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  Future<bool> requestSmsPermission() async {
    _setState(SmsProviderState.loading);
    
    final result = await _requestSmsPermissionUsecase();
    
    return result.fold(
      (failure) {
        _setError(failure.msg);
        return false;
      },
      (hasPermission) {
        _hasPermission = hasPermission;
        _setState(SmsProviderState.loaded);
        return hasPermission;
      },
    );
  }

  Future<void> getMpesaSms() async {
    if (!_hasPermission) {
      final granted = await requestSmsPermission();
      if (!granted) return;
    }

    _setState(SmsProviderState.loading);
    
    final result = await _getMpesaSmsUsecase();
    
    result.fold(
      (failure) => _setError(failure.msg),
      (messages) {
        _mpesaSms = messages;
        _setState(SmsProviderState.loaded);
      },
    );
  }

  Future<bool> createExpenseFromSms(SmsMessageModel sms) async {
    if (!sms.isTransactionMessage) return false;
    
    final amount = sms.extractAmount();
    if (amount == null) return false;
    
    final description = sms.extractDescription() ?? 'MPESA Transaction';
    final date = sms.extractTransactionDate() ?? DateTime.now();
    
    // Convert to int amount as required by the model
    final amountInt = (amount * 100).round(); // Store as integer cents
    
    // Determine the expense category based on business or person
    ExpenseCategory category = ExpenseCategory.miscellaneous;
    
    if (sms.isBusinessPayment()) {
      final businessName = sms.extractBusinessName();
      if (businessName != null) {
        category = await _getCategoryForBusiness(businessName);
        
        // Auto-save business if it doesn't exist
        await _saveBusinessIfNotExists(businessName, category);
      }
    } else if (sms.isPersonTransfer()) {
      final personName = sms.extractPersonName();
      final phoneNumber = sms.extractPhoneNumber();
      if (personName != null) {
        category = await _getCategoryForPerson(personName, phoneNumber);
        
        // Auto-save person if it doesn't exist
        await _savePersonIfNotExists(personName, phoneNumber, category);
      }
    }
    
    final now = DateTime.now();
    final isoDate = now.toIso8601String();
    
    // Create expense entity based on the app's existing structure
    final expense = ExpenseEntity(
      createdAt: isoDate,
      updatedAt: isoDate,
      category: category,
      amount: amountInt,
      note: description,
    );
    
    final result = await _createExpenseEntryUsecase(expense);
    
    return result.fold(
      (failure) {
        _setError(failure.msg);
        return false;
      },
      (_) => true,
    );
  }

  void _setState(SmsProviderState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(SmsProviderState.error);
  }

  // Business methods
  Future<void> loadBusinesses() async {
    final result = await _getBusinessesUsecase();

    result.fold(
      (failure) => _setError(failure.msg),
      (businesses) {
        _businesses = businesses;
        notifyListeners();
      },
    );
  }

  Future<BusinessModel?> getBusinessByName(String name) async {
    final result = await _getBusinessByNameUsecase(name);
    
    return result.fold(
      (failure) => null,
      (business) => business,
    );
  }

  Future<ExpenseCategory> _getCategoryForBusiness(String businessName) async {
    final business = await getBusinessByName(businessName);
    return business?.category ?? ExpenseCategory.miscellaneous;
  }

  Future<void> _saveBusinessIfNotExists(String businessName, ExpenseCategory category) async {
    final business = await getBusinessByName(businessName);
    
    if (business == null) {
      final now = DateTime.now();
      final newBusiness = BusinessModel(
        id: _uuid.v4(),
        name: businessName,
        category: category,
        createdAt: now,
        updatedAt: now,
        transactionCount: 1, // First transaction
      );
      
      await _saveBusinessUsecase(newBusiness);
      await loadBusinesses(); // Refresh the list
    } else {
      // Increment transaction count for existing business
      await incrementBusinessTransactionCount(business);
    }
  }

  Future<BusinessModel?> saveBusiness(BusinessModel business) async {
    final result = await _saveBusinessUsecase(business);
    
    return result.fold(
      (failure) {
        _setError(failure.msg);
        return null;
      },
      (savedBusiness) {
        loadBusinesses(); // Refresh the list
        return savedBusiness;
      },
    );
  }

  // Person methods
  Future<void> loadPersons() async {
    final result = await _getPersonsUsecase();

    result.fold(
      (failure) => _setError(failure.msg),
      (persons) {
        _persons = persons;
        notifyListeners();
      },
    );
  }

  Future<PersonModel?> getPersonByName(String name) async {
    final result = await _getPersonsUsecase();

    return result.fold(
      (failure) => null,
      (persons) {
        try {
          return persons.firstWhere(
            (person) => person.name.toLowerCase().trim() == name.toLowerCase().trim(),
          );
        } catch (_) {
          return null;
        }
      },
    );
  }

  Future<PersonModel?> getPersonByPhone(String phoneNumber) async {
    final result = await _getPersonsUsecase();

    return result.fold(
      (failure) => null,
      (persons) {
        try {
          return persons.firstWhere(
            (person) => person.phoneNumber == phoneNumber,
          );
        } catch (_) {
          return null;
        }
      },
    );
  }

  Future<ExpenseCategory> _getCategoryForPerson(String personName, String? phoneNumber) async {
    PersonModel? person;
    
    if (phoneNumber != null) {
      person = await getPersonByPhone(phoneNumber);
    }
    
    if (person == null) {
      person = await getPersonByName(personName);
    }
    
    return person?.category ?? ExpenseCategory.miscellaneous;
  }

  Future<void> _savePersonIfNotExists(String personName, String? phoneNumber, ExpenseCategory category) async {
    PersonModel? person;
    
    if (phoneNumber != null) {
      person = await getPersonByPhone(phoneNumber);
    }
    
    if (person == null) {
      person = await getPersonByName(personName);
    }
    
    if (person == null) {
      final now = DateTime.now();
      final newPerson = PersonModel(
        id: _uuid.v4(),
        name: personName,
        phoneNumber: phoneNumber,
        category: category,
        createdAt: now,
        updatedAt: now,
        transactionCount: 1, // First transaction
      );
      
      await _savePersonUsecase(newPerson);
      await loadPersons(); // Refresh the list
    } else {
      // Increment transaction count for existing person
      await incrementPersonTransactionCount(person);
    }
  }

  Future<PersonModel?> savePerson(PersonModel person) async {
    final result = await _savePersonUsecase(person);
    
    return result.fold(
      (failure) {
        _setError(failure.msg);
        return null;
      },
      (savedPerson) {
        loadPersons(); // Refresh the list
        return savedPerson;
      },
    );
  }

  // Transaction count management
  Future<void> incrementBusinessTransactionCount(BusinessModel business) async {
    final updatedBusiness = business.copyWith(
      transactionCount: business.transactionCount + 1,
      updatedAt: DateTime.now(),
    );
    await saveBusiness(updatedBusiness);
  }

  Future<void> incrementPersonTransactionCount(PersonModel person) async {
    final updatedPerson = person.copyWith(
      transactionCount: person.transactionCount + 1,
      updatedAt: DateTime.now(),
    );
    await savePerson(updatedPerson);
  }

  // Load all data
  Future<void> loadAllData() async {
    await loadBusinesses();
    await loadPersons();
  }
}
