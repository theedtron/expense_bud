import 'package:expense_bud/core/utils/category_items.dart';
import 'package:hive/hive.dart';

part 'business_model.g.dart';

@HiveType(typeId: 3)
class BusinessModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final ExpenseCategory category;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final int transactionCount;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.transactionCount = 0,
  });

  BusinessModel copyWith({
    String? id,
    String? name,
    ExpenseCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? transactionCount,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionCount': transactionCount,
    };
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'],
      category: _categoryFromString(json['category']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }

  static ExpenseCategory _categoryFromString(String categoryStr) {
    final categoryName = categoryStr.split('.').last;
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => ExpenseCategory.miscellaneous,
    );
  }
}
