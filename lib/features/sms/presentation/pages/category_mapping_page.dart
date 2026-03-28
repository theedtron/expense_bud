import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/core/widgets/gap.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/presentation/provider/sms_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryMappingPage extends StatefulWidget {
  const CategoryMappingPage({Key? key}) : super(key: key);

  @override
  State<CategoryMappingPage> createState() => _CategoryMappingPageState();
}

class _CategoryMappingPageState extends State<CategoryMappingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    await smsProvider.loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Mapping'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Businesses'),
            Tab(text: 'Persons'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BusinessMappingTab(),
          PersonMappingTab(),
        ],
      ),
    );
  }
}

class BusinessMappingTab extends StatelessWidget {
  const BusinessMappingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsProvider>(
      builder: (context, provider, child) {
        if (provider.businesses.isEmpty) {
          return const Center(
            child: Text('No businesses found. They will appear here when detected in M-PESA messages.'),
          );
        }

        return ListView.builder(
          itemCount: provider.businesses.length,
          itemBuilder: (context, index) {
            final business = provider.businesses[index];
            return BusinessListItem(business: business);
          },
        );
      },
    );
  }
}

class BusinessListItem extends StatelessWidget {
  final BusinessModel business;

  const BusinessListItem({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    business.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditBusinessDialog(context, business),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category:'),
                Chip(
                  label: Text(
                    _getCategoryDisplayName(business.category),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getCategoryColor(business.category),
                ),
              ],
            ),
            if (business.transactionCount > 0) ...[
              const Gap(8),
              Text('Transactions: ${business.transactionCount}'),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ExpenseCategory category) {
    String name = category.name;
    String displayName = name.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}');
    return displayName[0].toUpperCase() + displayName.substring(1);
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return Colors.red;
      case ExpenseCategory.fuel:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.drinkingWater:
        return Colors.lightBlue;
      case ExpenseCategory.cookingGas:
        return Colors.brown;
      case ExpenseCategory.nanny:
        return Colors.green;
      case ExpenseCategory.electricityBill:
        return Colors.yellow;
      case ExpenseCategory.waterBill:
        return Colors.cyan;
      case ExpenseCategory.internet:
        return Colors.indigo;
      case ExpenseCategory.netflix:
        return Colors.red[900]!;
      case ExpenseCategory.spotify:
        return Colors.green[400]!;
      case ExpenseCategory.airtime:
        return Colors.purple;
      case ExpenseCategory.beauty:
        return Colors.pinkAccent;
      case ExpenseCategory.entertainment:
        return Colors.purpleAccent;
      case ExpenseCategory.miscellaneous:
        return Colors.grey;
      case ExpenseCategory.overdraft:
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  void _showEditBusinessDialog(BuildContext context, BusinessModel business) {
    showDialog(
      context: context,
      builder: (context) => EditBusinessDialog(business: business),
    );
  }
}

class EditBusinessDialog extends StatefulWidget {
  final BusinessModel business;

  const EditBusinessDialog({Key? key, required this.business}) : super(key: key);

  @override
  State<EditBusinessDialog> createState() => _EditBusinessDialogState();
}

class _EditBusinessDialogState extends State<EditBusinessDialog> {
  late TextEditingController _nameController;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _selectedCategory = widget.business.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Business'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
            ),
          ),
          const Gap(16),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem<ExpenseCategory>(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _saveBusiness(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(ExpenseCategory category) {
    String name = category.name;
    String displayName = name.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}');
    return displayName[0].toUpperCase() + displayName.substring(1);
  }

  void _saveBusiness(BuildContext context) {
    final updatedBusiness = widget.business.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      updatedAt: DateTime.now(),
    );

    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    smsProvider.saveBusiness(updatedBusiness);
    
    Navigator.of(context).pop();
  }
}

class PersonMappingTab extends StatelessWidget {
  const PersonMappingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsProvider>(
      builder: (context, provider, child) {
        if (provider.persons.isEmpty) {
          return const Center(
            child: Text('No persons found. They will appear here when detected in M-PESA messages.'),
          );
        }

        return ListView.builder(
          itemCount: provider.persons.length,
          itemBuilder: (context, index) {
            final person = provider.persons[index];
            return PersonListItem(person: person);
          },
        );
      },
    );
  }
}

class PersonListItem extends StatelessWidget {
  final PersonModel person;

  const PersonListItem({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditPersonDialog(context, person),
                ),
              ],
            ),
            if (person.phoneNumber != null) ...[
              Text('Phone: ${person.phoneNumber}'),
              const Gap(8),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category:'),
                Chip(
                  label: Text(
                    _getCategoryDisplayName(person.category),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getCategoryColor(person.category),
                ),
              ],
            ),
            if (person.transactionCount > 0) ...[
              const Gap(8),
              Text('Transactions: ${person.transactionCount}'),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ExpenseCategory category) {
    String name = category.name;
    String displayName = name.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}');
    return displayName[0].toUpperCase() + displayName.substring(1);
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return Colors.red;
      case ExpenseCategory.fuel:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.drinkingWater:
        return Colors.lightBlue;
      case ExpenseCategory.cookingGas:
        return Colors.brown;
      case ExpenseCategory.nanny:
        return Colors.green;
      case ExpenseCategory.electricityBill:
        return Colors.yellow;
      case ExpenseCategory.waterBill:
        return Colors.cyan;
      case ExpenseCategory.internet:
        return Colors.indigo;
      case ExpenseCategory.netflix:
        return Colors.red[900]!;
      case ExpenseCategory.spotify:
        return Colors.green[400]!;
      case ExpenseCategory.airtime:
        return Colors.purple;
      case ExpenseCategory.beauty:
        return Colors.pinkAccent;
      case ExpenseCategory.entertainment:
        return Colors.purpleAccent;
      case ExpenseCategory.miscellaneous:
        return Colors.grey;
      case ExpenseCategory.overdraft:
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  void _showEditPersonDialog(BuildContext context, PersonModel person) {
    showDialog(
      context: context,
      builder: (context) => EditPersonDialog(person: person),
    );
  }
}

class EditPersonDialog extends StatefulWidget {
  final PersonModel person;

  const EditPersonDialog({Key? key, required this.person}) : super(key: key);

  @override
  State<EditPersonDialog> createState() => _EditPersonDialogState();
}

class _EditPersonDialogState extends State<EditPersonDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _phoneController = TextEditingController(text: widget.person.phoneNumber ?? '');
    _selectedCategory = widget.person.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Person'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Person Name',
            ),
          ),
          const Gap(16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number (Optional)',
            ),
            keyboardType: TextInputType.phone,
          ),
          const Gap(16),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem<ExpenseCategory>(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _savePerson(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(ExpenseCategory category) {
    String name = category.name;
    String displayName = name.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}');
    return displayName[0].toUpperCase() + displayName.substring(1);
  }

  void _savePerson(BuildContext context) {
    final phoneNumber = _phoneController.text.trim().isEmpty 
        ? null 
        : _phoneController.text.trim();
        
    final updatedPerson = widget.person.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: phoneNumber,
      category: _selectedCategory,
      updatedAt: DateTime.now(),
    );

    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    smsProvider.savePerson(updatedPerson);
    
    Navigator.of(context).pop();
  }
}
