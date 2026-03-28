import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ISmsLocalDataSource {
  Future<List<SmsMessageModel>> getAllSms();
  Future<List<SmsMessageModel>> getMpesaSms();
  Future<bool> requestSmsPermission();
  Future<bool> checkSmsPermission();
}

class SmsLocalDataSource implements ISmsLocalDataSource {
  final SmsQuery _smsQuery = SmsQuery();

  @override
  Future<List<SmsMessageModel>> getAllSms() async {
    final hasPermission = await checkSmsPermission();
    if (!hasPermission) {
      return [];
    }

    final messages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 100, // Limit to most recent messages
    );

    return messages.map((msg) => SmsMessageModel.fromSmsMessage(msg)).toList();
  }

  @override
  Future<List<SmsMessageModel>> getMpesaSms() async {
    final allMessages = await getAllSms();
    return allMessages.where((msg) => msg.isMpesa).toList();
  }

  @override
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  @override
  Future<bool> checkSmsPermission() async {
    return await Permission.sms.status.isGranted;
  }
}
