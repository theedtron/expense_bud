import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/domain/usecases/usecase.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/business_repository.dart';

class SaveBusinessUsecase implements UsecaseOfFuture<BusinessModel, BusinessModel> {
  final BusinessRepository _repository;

  SaveBusinessUsecase(this._repository);

  @override
  Future<Either<Failure, BusinessModel>> call(BusinessModel params) {
    return _repository.saveBusiness(params);
  }
}
