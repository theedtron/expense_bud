import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/domain/repositories/sms_repository.dart';

class RequestSmsPermissionUsecase {
  final ISmsRepository _repository;

  RequestSmsPermissionUsecase(this._repository);

  Future<Either<Failure, bool>> call() async {
    return await _repository.requestSmsPermission();
  }
}
