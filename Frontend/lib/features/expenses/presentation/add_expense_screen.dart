import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_models.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedGroup;
  String? _selectedCategory;
  DateTime _date = DateTime.now();
  List<ExpenseParticipant> _participants = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await ref.read(expenseControllerProvider.notifier).parseReceipt(file);
    final suggestion = ref.read(receiptSuggestionProvider);
    if (suggestion != null) {
      setState(() {
        if (suggestion.merchant != null) {
          _titleController.text = suggestion.merchant!;
        }
        if (suggestion.total != null) {
          _amountController.text = suggestion.total!.toStringAsFixed(2);
        }
        if (suggestion.date != null) {
          final parsed = DateTime.tryParse(suggestion.date!);
          if (parsed != null) {
            _date = parsed;
          }
        }
      });
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Receipt scanned successfully');
    }
  }

  void _addParticipant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ParticipantSheet(
        onAdd: (participantId, share) {
          setState(() {
            _participants = [
              ..._participants,
              ExpenseParticipant(
                participantId: participantId,
                share: share,
              ),
            ];
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authControllerProvider).value;
    if (auth == null) return;
    if (_selectedGroup == null) {
      AppSnackBar.showError(context, 'Select a group');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      AppSnackBar.showError(context, 'Enter a valid amount');
      return;
    }
    if (_participants.isEmpty) {
      AppSnackBar.showError(context, 'Add at least one participant');
      return;
    }

    final draft = ExpenseDraft(
      groupId: _selectedGroup!,
      title: _titleController.text.trim(),
      amount: amount,
      paidBy: auth.id,
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      occurredAt: _date,
      split: _participants,
    );

    await ref.read(expenseControllerProvider.notifier).createExpense(draft);

    final state = ref.read(expenseControllerProvider);
    if (state.hasError) {
      AppSnackBar.showError(context, state.error.toString());
      return;
    }

    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Expense added');
    setState(() {
      _titleController.clear();
      _amountController.clear();
      _notesController.clear();
      _participants = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupsState = ref.watch(dashboardProvider);
    final expenseState = ref.watch(expenseControllerProvider);
    final suggestion = ref.watch(receiptSuggestionProvider);

    final dateFormat = DateFormat.yMMMMd();

    return Scaffold(
      body: SafeArea(
        child: groupsState.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.group_add_outlined,
                  title: 'Create a group first',
                  message:
                      'You need at least one group before you can add expenses.',
                ),
              );
            }

            _selectedGroup ??= groups.first.id;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            expenseState.isLoading ? null : () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      Text(
                        'New expense',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedGroup,
                    items: groups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group.id,
                            child: Text(group.name),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select group',
                      prefixIcon: Icon(Icons.groups_2_outlined),
                    ),
                    onChanged: expenseState.isLoading
                        ? null
                        : (value) => setState(() => _selectedGroup = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'What was this for?',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter an amount';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: const [
                      DropdownMenuItem(
                        value: 'food',
                        child: Text('Food & groceries'),
                      ),
                      DropdownMenuItem(
                        value: 'travel',
                        child: Text('Travel'),
                      ),
                      DropdownMenuItem(
                        value: 'utilities',
                        child: Text('Utilities'),
                      ),
                      DropdownMenuItem(
                        value: 'entertainment',
                        child: Text('Entertainment'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    onChanged: expenseState.isLoading
                        ? null
                        : (value) => setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Date'),
                    subtitle: Text(dateFormat.format(_date)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: expenseState.isLoading
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                  ),
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Scan receipt'),
                    subtitle: Text(
                      suggestion == null
                          ? 'Extract totals directly from a bill photo'
                          : 'Receipt scanned, review values above',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.document_scanner_outlined),
                      onPressed:
                          expenseState.isLoading ? null : () => _pickReceipt(),
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Participants',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_participants.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Split this expense by adding participants and shares.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ..._participants.map(
                    (participant) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surfaceVariant
                            .withOpacity(0.35),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              participant.participantId,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            'Share: ${participant.share.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: expenseState.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _participants = _participants
                                          .where((p) =>
                                              p.participantId !=
                                              participant.participantId)
                                          .toList();
                                    });
                                  },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: expenseState.isLoading ? null : _addParticipant,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Add participant'),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: expenseState.isLoading ? null : _submit,
                      child: expenseState.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Save expense'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) => Center(
            child: EmptyState(
              icon: Icons.warning_amber_rounded,
              title: 'Unable to load groups',
              message: error.toString(),
              actionLabel: 'Retry',
              onAction: () =>
                  ref.read(dashboardProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantSheet extends StatefulWidget {
  const _ParticipantSheet({required this.onAdd});

  final void Function(String participantId, double share) onAdd;

  @override
  State<_ParticipantSheet> createState() => _ParticipantSheetState();
}

class _ParticipantSheetState extends State<_ParticipantSheet> {
  final _formKey = GlobalKey<FormState>();
  final _participantController = TextEditingController();
  final _shareController = TextEditingController(text: '1');

  @override
  void dispose() {
    _participantController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final share = double.parse(_shareController.text);
    widget.onAdd(_participantController.text.trim(), share);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: viewInsets + 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add participant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _participantController,
              decoration: const InputDecoration(
                labelText: 'Email or user ID',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a participant';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shareController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Share',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a share amount';
                }
                final share = double.tryParse(value);
                if (share == null || share <= 0) {
                  return 'Enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


