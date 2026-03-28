import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/business_repository.dart';

class GetBusinessesUsecase implements NoArgsUsecaseOfFuture<List<BusinessModel>> {
  final BusinessRepository _repository;

  GetBusinessesUsecase(this._repository);

  @override
  Future<Either<Failure, List<BusinessModel>>> call() {
    return _repository.getBusinesses();
  }
}
