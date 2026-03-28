import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/sms_repository.dart';

class GetMpesaSmsUsecase {
  final ISmsRepository _repository;

  GetMpesaSmsUsecase(this._repository);

  Future<Either<Failure, List<SmsMessageModel>>> call() async {
    return await _repository.getMpesaSms();
  }
}
