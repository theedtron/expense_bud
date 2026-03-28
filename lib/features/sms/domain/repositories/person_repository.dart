import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';

abstract class PersonRepository {
  Future<Either<Failure, List<PersonModel>>> getPersons();
  Future<Either<Failure, PersonModel?>> getPersonByName(String name);
  Future<Either<Failure, PersonModel?>> getPersonByPhone(String phoneNumber);
  Future<Either<Failure, PersonModel>> savePerson(PersonModel person);
  Future<Either<Failure, PersonModel>> updatePerson(PersonModel person);
  Future<Either<Failure, void>> deletePerson(String id);
  Future<Either<Failure, ExpenseCategory>> getCategoryForPerson(String personName, {String? phoneNumber});
}
