import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/sms/data/datasources/sms_local_datasource.dart';
import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';
import 'package:expense_bud/features/sms/domain/repositories/sms_repository.dart';

class SmsRepository implements ISmsRepository {
  final ISmsLocalDataSource _dataSource;

  SmsRepository(this._dataSource);

  @override
  Future<Either<Failure, List<SmsMessageModel>>> getAllSms() async {
    try {
      final result = await _dataSource.getAllSms();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SmsMessageModel>>> getMpesaSms() async {
    try {
      final result = await _dataSource.getMpesaSms();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> requestSmsPermission() async {
    try {
      final result = await _dataSource.requestSmsPermission();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(Exception(e.toString())));
    }
  }
}
