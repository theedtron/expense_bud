import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';

abstract class ISmsRepository {
  Future<Either<Failure, List<SmsMessageModel>>> getAllSms();
  Future<Either<Failure, List<SmsMessageModel>>> getMpesaSms();
  Future<Either<Failure, bool>> requestSmsPermission();
}
