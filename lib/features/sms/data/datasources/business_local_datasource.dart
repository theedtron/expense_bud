import 'package:expense_bud/core/failure/exceptions.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

abstract class BusinessLocalDatasource {
  Future<List<BusinessModel>> getBusinesses();
  Future<BusinessModel?> getBusinessByName(String name);
  Future<BusinessModel> saveBusiness(BusinessModel business);
  Future<BusinessModel> updateBusiness(BusinessModel business);
  Future<void> deleteBusiness(String id);
  Future<ExpenseCategory> getCategoryForBusiness(String businessName);
}

class BusinessLocalDatasourceImpl implements BusinessLocalDatasource {
  final Box<BusinessModel> _businessBox;
  final Uuid _uuid;

  BusinessLocalDatasourceImpl({
    required Box<BusinessModel> businessBox,
  }) : _businessBox = businessBox, 
       _uuid = const Uuid();

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      return _businessBox.values.toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<BusinessModel?> getBusinessByName(String name) async {
    try {
      final normalizedName = name.toLowerCase().trim();
      return _businessBox.values.firstWhere(
        (business) => business.name.toLowerCase().trim() == normalizedName,
        orElse: () => throw NotFoundException('Business not found'),
      );
    } catch (e) {
      if (e is NotFoundException) {
        return null;
      }
      throw CacheException(e.toString());
    }
  }

  @override
  Future<BusinessModel> saveBusiness(BusinessModel business) async {
    try {
      final now = DateTime.now();
      final newBusiness = business.copyWith(
        id: business.id.isEmpty ? _uuid.v4() : business.id,
        createdAt: now,
        updatedAt: now,
      );
      
      await _businessBox.put(newBusiness.id, newBusiness);
      return newBusiness;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<BusinessModel> updateBusiness(BusinessModel business) async {
    try {
      if (!_businessBox.containsKey(business.id)) {
        throw NotFoundException('Business not found');
      }
      
      final updatedBusiness = business.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _businessBox.put(updatedBusiness.id, updatedBusiness);
      return updatedBusiness;
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> deleteBusiness(String id) async {
    try {
      await _businessBox.delete(id);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<ExpenseCategory> getCategoryForBusiness(String businessName) async {
    try {
      final business = await getBusinessByName(businessName);
      return business?.category ?? ExpenseCategory.miscellaneous;
    } catch (e) {
      return ExpenseCategory.miscellaneous;
    }
  }
}
