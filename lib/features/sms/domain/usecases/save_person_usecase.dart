import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/person_repository.dart';

class SavePersonUsecase implements UsecaseOfFuture<PersonModel, PersonModel> {
  final PersonRepository _repository;

  SavePersonUsecase(this._repository);

  @override
  Future<Either<Failure, PersonModel>> call(PersonModel params) {
    return _repository.savePerson(params);
  }
}
