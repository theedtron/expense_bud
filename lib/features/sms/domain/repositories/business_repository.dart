import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';

abstract class BusinessRepository {
  Future<Either<Failure, List<BusinessModel>>> getBusinesses();
  Future<Either<Failure, BusinessModel?>> getBusinessByName(String name);
  Future<Either<Failure, BusinessModel>> saveBusiness(BusinessModel business);
  Future<Either<Failure, BusinessModel>> updateBusiness(BusinessModel business);
  Future<Either<Failure, void>> deleteBusiness(String id);
  Future<Either<Failure, ExpenseCategory>> getCategoryForBusiness(String businessName);
}
