import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/exceptions.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/datasources/business_local_datasource.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/core/failure/exceptions.dart';
import 'package:expense_bud/features/sms/domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDatasource _localDatasource;

  BusinessRepositoryImpl({
    required BusinessLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  @override
  Future<Either<Failure, List<BusinessModel>>> getBusinesses() async {
    try {
      final businesses = await _localDatasource.getBusinesses();
      return Right(businesses);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, BusinessModel?>> getBusinessByName(String name) async {
    try {
      final business = await _localDatasource.getBusinessByName(name);
      return Right(business);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, BusinessModel>> saveBusiness(BusinessModel business) async {
    try {
      final savedBusiness = await _localDatasource.saveBusiness(business);
      return Right(savedBusiness);
    } on CacheException {
      return Left(CachePutFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, BusinessModel>> updateBusiness(BusinessModel business) async {
    try {
      final updatedBusiness = await _localDatasource.updateBusiness(business);
      return Right(updatedBusiness);
    } on NotFoundException {
      return Left(NotFoundFailure());
    } on CacheException {
      return Left(CachePutFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBusiness(String id) async {
    try {
      await _localDatasource.deleteBusiness(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> getCategoryForBusiness(String businessName) async {
    try {
      final category = await _localDatasource.getCategoryForBusiness(businessName);
      return Right(category);
    } catch (e) {
      // Default to miscellaneous category if any error occurs
            return const Right(ExpenseCategory.miscellaneous);
    }
  }
}
