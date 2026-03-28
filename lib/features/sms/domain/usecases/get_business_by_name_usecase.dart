import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/business_repository.dart';

class GetBusinessByNameUsecase implements UsecaseOfFuture<BusinessModel?, String> {
  final BusinessRepository _repository;

  GetBusinessByNameUsecase(this._repository);

  @override
  Future<Either<Failure, BusinessModel?>> call(String params) {
    return _repository.getBusinessByName(params);
  }
}
