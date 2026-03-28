import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsMessageModel {
  final String? id;
  final String? address;
  final String? body;
  final DateTime? date;
  final bool? read;
  final String? type; // Incoming or Outgoing
  
  // Transaction ID from M-PESA message
  String? transactionId;

  SmsMessageModel({
    this.id,
    this.address,
    this.body,
    this.date,
    this.read,
    this.type,
    this.transactionId,
  });

  factory SmsMessageModel.fromSmsMessage(SmsMessage message) {
    final model = SmsMessageModel(
      id: message.id?.toString(),
      address: message.address,
      body: message.body,
      date: message.date,
      read: message.read,
      type: message.kind.toString(),
    );
    
    // Extract transaction ID if available
    model.transactionId = model.extractTransactionId();
    
    return model;
  }

  bool get isMpesa => 
    address != null && 
    (address!.toLowerCase().contains('mpesa') || 
     address!.toLowerCase().contains('m-pesa') ||
     address == 'MPESA');

  bool get isTransactionMessage {
    if (body == null) return false;
    
    final bodyLower = body!.toLowerCase();
    return isMpesa && (
      bodyLower.contains('transaction') || 
      bodyLower.contains('sent') || 
      bodyLower.contains('paid') ||
      bodyLower.contains('received') ||
      bodyLower.contains('withdraw') ||
      bodyLower.contains('deposit')
    );
  }

  double? extractAmount() {
    if (body == null) return null;
    
    // Look for patterns like "Ksh1,000.00" or "KES 1,000.00"
    final regex = RegExp(r'(?:Ksh|KES)\s?([0-9,]+\.[0-9]+)');
    final match = regex.firstMatch(body!);
    
    if (match != null && match.groupCount >= 1) {
      final amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    
    return null;
  }

  String? extractDescription() {
    if (body == null) return null;
    
    if (isBusinessPayment()) {
      return 'Payment to ${extractBusinessName() ?? "Business"}';
    } else if (isPersonTransfer()) {
      return 'Transfer to ${extractPersonName() ?? "Person"}';
    }
    
    return "MPESA Transaction";
  }

  bool isBusinessPayment() {
    if (body == null) return false;
    
    final bodyLower = body!.toLowerCase();
    return bodyLower.contains('paid to') || 
           bodyLower.contains('payment to') || 
           bodyLower.contains('buy goods');
  }

  bool isPersonTransfer() {
    if (body == null) return false;
    
    final bodyLower = body!.toLowerCase();
    return bodyLower.contains('sent to') || 
           bodyLower.contains('transfer to') || 
           bodyLower.contains('sent money to');
  }

  String? extractBusinessName() {
    if (body == null || !isBusinessPayment()) return null;
    
    // Pattern for "Paid to BUSINESS_NAME"
    final paidToRegex = RegExp(r'paid to ([^.]+)', caseSensitive: false);
    final paidToMatch = paidToRegex.firstMatch(body!);
    
    if (paidToMatch != null && paidToMatch.groupCount >= 1) {
      return paidToMatch.group(1)?.trim();
    }
    
    // Pattern for "Buy Goods and Services from BUSINESS_NAME"
    final buyGoodsRegex = RegExp(r'from ([^.]+)', caseSensitive: false);
    final buyGoodsMatch = buyGoodsRegex.firstMatch(body!);
    
    if (buyGoodsMatch != null && buyGoodsMatch.groupCount >= 1) {
      return buyGoodsMatch.group(1)?.trim();
    }
    
    return null;
  }

  String? extractPersonName() {
    if (body == null || !isPersonTransfer()) return null;
    
    // Pattern for "Sent to PERSON_NAME"
    final sentToRegex = RegExp(r'sent to ([^.]+)', caseSensitive: false);
    final sentToMatch = sentToRegex.firstMatch(body!);
    
    if (sentToMatch != null && sentToMatch.groupCount >= 1) {
      return sentToMatch.group(1)?.trim();
    }
    
    return null;
  }

  String? extractPhoneNumber() {
    if (body == null) return null;
    
    // Pattern for phone numbers in the format 254XXXXXXXXX or 07XXXXXXXX
    final phoneRegex = RegExp(r'(254\d{9}|0\d{9})');
    final phoneMatch = phoneRegex.firstMatch(body!);
    
    if (phoneMatch != null && phoneMatch.groupCount >= 1) {
      return phoneMatch.group(0);
    }
    
    return null;
  }

  String? extractTransactionId() {
    if (body == null) return null;
    
    // Pattern for transaction ID like "NLJ7QWQOPM"
    final regex = RegExp(r'([A-Z0-9]{10})');
    final match = regex.firstMatch(body!);
    
    if (match != null && match.groupCount >= 0) {
      return match.group(0);
    }
    
    return null;
  }

  /// Extract transaction date if available
  DateTime? extractTransactionDate() {
    return date; // Using the SMS date as transaction date
  }
}
