import 'package:expense_bud/config/theme.dart';
import 'package:expense_bud/core/domain/entities/expense.dart';
import 'package:expense_bud/core/utils/category_items.dart';
import 'package:expense_bud/core/widgets/gap.dart';
import 'package:expense_bud/features/expense/presentation/provider/expense_provider.dart';
import 'package:expense_bud/features/settings/presentation/providers/settings_provider.dart';
import 'package:expense_bud/features/sms/data/models/business_model.dart';
import 'package:expense_bud/features/sms/data/models/person_model.dart';
import 'package:expense_bud/features/sms/data/models/sms_message_model.dart';
import 'package:expense_bud/features/sms/presentation/pages/category_mapping_page.dart';
import 'package:expense_bud/features/sms/presentation/provider/sms_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class SmsReaderPage extends StatefulWidget {
  const SmsReaderPage({Key? key}) : super(key: key);

  @override
  State<SmsReaderPage> createState() => _SmsReaderPageState();
}

class _SmsReaderPageState extends State<SmsReaderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermission();
      _loadMappingData();
    });
  }
  
  Future<void> _loadMappingData() async {
    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    await smsProvider.loadAllData();
  }

  Future<void> _checkPermission() async {
    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    final hasPermission = await smsProvider.requestSmsPermission();
    
    if (hasPermission) {
      smsProvider.getMpesaSms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-PESA Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            onPressed: () {
              Provider.of<SmsProvider>(context, listen: false).getMpesaSms();
            },
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.gear),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryMappingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SmsProvider>(
        builder: (context, smsProvider, child) {
          if (smsProvider.state == SmsProviderState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (smsProvider.state == SmsProviderState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${smsProvider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: () => smsProvider.requestSmsPermission(),
                    child: const Text('Grant SMS Permission'),
                  ),
                ],
              ),
            );
          } else if (!smsProvider.hasPermission) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SMS permission is required to read M-PESA messages.',
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: () => smsProvider.requestSmsPermission(),
                    child: const Text('Grant SMS Permission'),
                  ),
                ],
              ),
            );
          } else if (smsProvider.mpesaSms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.chatCenteredText,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const Gap(16),
                  Text(
                    'No M-PESA messages found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await smsProvider.getMpesaSms();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: smsProvider.mpesaSms.length,
              itemBuilder: (context, index) {
                final sms = smsProvider.mpesaSms[index];
                return MpesaSmsCard(sms: sms);
              },
            ),
          );
        },
      ),
    );
  }
}

class MpesaSmsCard extends StatefulWidget {
  final SmsMessageModel sms;

  const MpesaSmsCard({Key? key, required this.sms}) : super(key: key);

  @override
  State<MpesaSmsCard> createState() => _MpesaSmsCardState();
}

class _MpesaSmsCardState extends State<MpesaSmsCard> {
  BusinessModel? _business;
  PersonModel? _person;
  ExpenseCategory? _category;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntityData();
  }

  Future<void> _loadEntityData() async {
    setState(() => _isLoading = true);
    
    final smsProvider = Provider.of<SmsProvider>(context, listen: false);
    
    if (widget.sms.isBusinessPayment()) {
      final businessName = widget.sms.extractBusinessName();
      if (businessName != null) {
        _business = await smsProvider.getBusinessByName(businessName);
        if (_business != null) {
          _category = _business!.category;
        }
      }
    } else if (widget.sms.isPersonTransfer()) {
      final personName = widget.sms.extractPersonName();
      final phoneNumber = widget.sms.extractPhoneNumber();
      
      if (phoneNumber != null) {
        _person = await smsProvider.getPersonByPhone(phoneNumber);
      }
      
      if (_person == null && personName != null) {
        _person = await smsProvider.getPersonByName(personName);
      }
      
      if (_person != null) {
        _category = _person!.category;
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.sms.extractAmount();
    final description = widget.sms.extractDescription();
    final date = widget.sms.date;
    final businessName = widget.sms.extractBusinessName();
    final personName = widget.sms.extractPersonName();
    final phoneNumber = widget.sms.extractPhoneNumber();
    final transactionId = widget.sms.extractTransactionId();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.sms.isBusinessPayment()
                          ? PhosphorIconsFill.storefront
                          : widget.sms.isPersonTransfer()
                              ? PhosphorIconsFill.user
                              : PhosphorIconsFill.wallet,
                      color: AppColors.kPrimary,
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sms.isBusinessPayment()
                              ? 'Business Payment'
                              : widget.sms.isPersonTransfer()
                                  ? 'Person Transfer'
                                  : 'M-PESA Transaction',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (date != null)
                          Text(
                            '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                      ],
                    ),
                  const Gap(12),
                  if (businessName != null || personName != null)
                    _buildInfoRow(
                      context,
                      PhosphorIconsRegular.user,
                      businessName ?? personName ?? '',
                    ),
                  if (phoneNumber != null)
                    _buildInfoRow(
                      context,
                      PhosphorIconsRegular.phone,
                      phoneNumber,
                    ),
                  if (transactionId != null)
                    _buildInfoRow(
                      context,
                      PhosphorIconsRegular.hash,
                      transactionId,
                    ),
                
                  if (_category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            avatar: Icon(
                              _getCategoryIcon(_category!),
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              _getCategoryDisplayName(_category!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _getCategoryColor(_category!),
                          ),
                        ],
                        label: const Text('Edit & Add'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showEditTransactionDialog(context),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                        label: const Text('Quick Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.kPrimary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _quickAddExpense(context),
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
}
