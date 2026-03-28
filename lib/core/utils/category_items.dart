import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum ExpenseCategory {
  rent,
  fuel,
  transport,
  shopping,
  drinkingWater,
  cookingGas,
  nanny,
  electricityBill,
  waterBill,
  internet,
  netflix,
  spotify,
  airtime,
  miscellaneous,
  beauty,
  entertainment,
  overdraft
}

class ExpenseCategoryItem {
  final String title;
  final ExpenseCategory category;
  final IconData iconData;
  final Color color;

  const ExpenseCategoryItem({
    required this.title,
    required this.category,
    required this.iconData,
    this.color = Colors.grey,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseCategoryItem &&
        other.title == title &&
        other.category == category;
  }

  @override
  int get hashCode => title.hashCode ^ category.hashCode;
}

List<ExpenseCategoryItem> categoryItems() => const [
      ExpenseCategoryItem(
        title: 'Rent',
        category: ExpenseCategory.rent,
        iconData: PhosphorIconsFill.house,
        color: Color(0xFFF8C795),
      ),
      ExpenseCategoryItem(
        title: 'Fuel',
        category: ExpenseCategory.fuel,
        iconData: PhosphorIconsFill.gasPump,
        color: Color(0xFF71B3FC),
      ),
      ExpenseCategoryItem(
        title: 'Transport',
        category: ExpenseCategory.transport,
        iconData: PhosphorIconsFill.taxi,
        color: Color(0xFF567FFB),
      ),
      ExpenseCategoryItem(
        title: 'Shopping',
        category: ExpenseCategory.shopping,
        iconData: PhosphorIconsFill.shoppingCart,
        color: Color(0xFF84E9C7),
      ),
      ExpenseCategoryItem(
        title: 'Drinking Water',
        category: ExpenseCategory.drinkingWater,
        iconData: PhosphorIconsFill.drop,
        color: Color(0xFFEF80A2),
      ),
      ExpenseCategoryItem(
        title: 'Cooking Gas',
        category: ExpenseCategory.cookingGas,
        iconData: PhosphorIconsFill.fire,
        color: Color(0xFFF5B5B6),
      ),
      ExpenseCategoryItem(
        title: 'Nanny',
        category: ExpenseCategory.nanny,
        iconData: PhosphorIconsFill.person,
        color: Color(0xFFF8BA58),
      ),
      ExpenseCategoryItem(
        title: 'Electricity Bill',
        category: ExpenseCategory.electricityBill,
            iconData: PhosphorIconsFill.lightbulb,
        color: Color(0xFFCDDD36),
      ),
      ExpenseCategoryItem(
        title: 'Water Bill',
        category: ExpenseCategory.waterBill,
        color: Color(0xFFDD3636),
        iconData: PhosphorIconsFill.drop,
      ),
      ExpenseCategoryItem(
        title: 'Internet',
        category: ExpenseCategory.internet,
        iconData: PhosphorIconsFill.network,
        color: Color(0xFFDD9736),
      ),
      ExpenseCategoryItem(
        title: 'Netflix',
        category: ExpenseCategory.netflix,
        iconData: PhosphorIconsFill.televisionSimple,
        color: Color(0xFFDDCD36),
      ),
      ExpenseCategoryItem(
        title: 'Spotify',
        category: ExpenseCategory.spotify,
        iconData: PhosphorIconsFill.headphones,
        color: Color(0xFF93DD36),
      ),
      ExpenseCategoryItem(
        title: 'Airtime',
        category: ExpenseCategory.airtime,
        iconData: PhosphorIconsFill.phone,
        color: Color(0xFF36CADD),
      ),
      ExpenseCategoryItem(
        title: 'Beauty',
        category: ExpenseCategory.beauty,
        iconData: PhosphorIconsFill.hairDryer,
        color: Color(0xFF36B5DD),
      ),
      ExpenseCategoryItem(
        title: 'Entertainment',
        category: ExpenseCategory.entertainment,
        iconData: PhosphorIconsFill.pizza,
        color: Color(0xFF366CDD),
      ),
      ExpenseCategoryItem(
        title: 'Miscellaneous',
        category: ExpenseCategory.miscellaneous,
        iconData: PhosphorIconsFill.asterisk,
        color: Color(0xFF9A36DD),
      ),
      ExpenseCategoryItem(
        title: 'Overdraft',
        category: ExpenseCategory.overdraft,
        iconData: PhosphorIconsFill.money,
        color: Color(0xFF9A36DD),
      ),
];
