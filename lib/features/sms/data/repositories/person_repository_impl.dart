import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/exceptions.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/datasources/person_local_datasource.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonLocalDatasource _localDatasource;

  PersonRepositoryImpl({
    required PersonLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  @override
  Future<Either<Failure, List<PersonModel>>> getPersons() async {
    try {
      final persons = await _localDatasource.getPersons();
      return Right(persons);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, PersonModel?>> getPersonByName(String name) async {
    try {
      final person = await _localDatasource.getPersonByName(name);
      return Right(person);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, PersonModel?>> getPersonByPhone(String phoneNumber) async {
    try {
      final person = await _localDatasource.getPersonByPhone(phoneNumber);
      return Right(person);
    } on CacheException {
      return Left(CacheGetFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, PersonModel>> savePerson(PersonModel person) async {
    try {
      final savedPerson = await _localDatasource.savePerson(person);
      return Right(savedPerson);
    } on CacheException {
      return Left(CachePutFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, PersonModel>> updatePerson(PersonModel person) async {
    try {
      final updatedPerson = await _localDatasource.updatePerson(person);
      return Right(updatedPerson);
    } on NotFoundException {
      return Left(NotFoundFailure());
    } on CacheException {
      return Left(CachePutFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> deletePerson(String id) async {
    try {
      await _localDatasource.deletePerson(id);
      return const Right(null);
    } on CacheException {
      return Left(CachePutFailure());
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> getCategoryForPerson(String personName, {String? phoneNumber}) async {
    try {
      final category = await _localDatasource.getCategoryForPerson(personName, phoneNumber: phoneNumber);
      return Right(category);
    } catch (e) {
      // Default to miscellaneous category if any error occurs
      return const Right(ExpenseCategory.miscellaneous);
    }
  }
}
