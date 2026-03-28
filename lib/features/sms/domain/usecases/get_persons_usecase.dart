import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/person_repository.dart';

class GetPersonsUsecase implements NoArgsUsecaseOfFuture<List<PersonModel>> {
  final PersonRepository _repository;

  GetPersonsUsecase(this._repository);

  @override
  Future<Either<Failure, List<PersonModel>>> call() {
    return _repository.getPersons();
  }
}
