import 'package:expense_bud/core/utils/category_items.dart';
import 'package:hive/hive.dart';

part 'person_model.g.dart';

@HiveType(typeId: 4)
class PersonModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final ExpenseCategory category;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final int transactionCount;

  PersonModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.transactionCount = 0,
  });

  PersonModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    ExpenseCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? transactionCount,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
      'phoneNumber': phoneNumber,
      'category': category.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionCount': transactionCount,
    };
  }

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
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
