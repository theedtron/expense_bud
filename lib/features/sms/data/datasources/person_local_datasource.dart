import 'package:expense_bud/core/failure/exceptions.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

abstract class PersonLocalDatasource {
  Future<List<PersonModel>> getPersons();
  Future<PersonModel?> getPersonByName(String name);
  Future<PersonModel?> getPersonByPhone(String phoneNumber);
  Future<PersonModel> savePerson(PersonModel person);
  Future<PersonModel> updatePerson(PersonModel person);
  Future<void> deletePerson(String id);
  Future<ExpenseCategory> getCategoryForPerson(String personName, {String? phoneNumber});
}

class PersonLocalDatasourceImpl implements PersonLocalDatasource {
  final Box<PersonModel> _personBox;
  final Uuid _uuid;

  PersonLocalDatasourceImpl({
    required Box<PersonModel> personBox,
  }) : _personBox = personBox, 
       _uuid = const Uuid();

  @override
  Future<List<PersonModel>> getPersons() async {
    try {
      return _personBox.values.toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<PersonModel?> getPersonByName(String name) async {
    try {
      final normalizedName = name.toLowerCase().trim();
      return _personBox.values.firstWhere(
        (person) => person.name.toLowerCase().trim() == normalizedName,
        orElse: () => throw NotFoundException('Person not found'),
      );
    } catch (e) {
      if (e is NotFoundException) {
        return null;
      }
      throw CacheException(e.toString());
    }
  }

  @override
  Future<PersonModel?> getPersonByPhone(String phoneNumber) async {
    try {
      final normalizedPhone = phoneNumber.trim();
      return _personBox.values.firstWhere(
        (person) => person.phoneNumber?.trim() == normalizedPhone,
        orElse: () => throw NotFoundException('Person not found'),
      );
    } catch (e) {
      if (e is NotFoundException) {
        return null;
      }
      throw CacheException(e.toString());
    }
  }

  @override
  Future<PersonModel> savePerson(PersonModel person) async {
    try {
      final now = DateTime.now();
      final newPerson = person.copyWith(
        id: person.id.isEmpty ? _uuid.v4() : person.id,
        createdAt: now,
        updatedAt: now,
      );
      
      await _personBox.put(newPerson.id, newPerson);
      return newPerson;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<PersonModel> updatePerson(PersonModel person) async {
    try {
      if (!_personBox.containsKey(person.id)) {
        throw NotFoundException('Person not found');
      }
      
      final updatedPerson = person.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _personBox.put(updatedPerson.id, updatedPerson);
      return updatedPerson;
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> deletePerson(String id) async {
    try {
      await _personBox.delete(id);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<ExpenseCategory> getCategoryForPerson(String personName, {String? phoneNumber}) async {
    try {
      PersonModel? person;
      
      // Try to find by phone number first if provided
      if (phoneNumber != null) {
        person = await getPersonByPhone(phoneNumber);
      }
      
      // If not found by phone, try by name
      if (person == null) {
        person = await getPersonByName(personName);
      }
      
      return person?.category ?? ExpenseCategory.miscellaneous;
    } catch (e) {
      return ExpenseCategory.miscellaneous;
    }
  }
}
