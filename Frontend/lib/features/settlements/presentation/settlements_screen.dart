import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/settlement_controller.dart';
import '../models/settlement_model.dart';

class SettlementsScreen extends ConsumerWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settlementsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(settlementsProvider.notifier).refresh(),
      child: state.when(
        data: (settlements) {
          if (settlements.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                EmptyState(
                  icon: Icons.payments_outlined,
                  title: 'No settlements yet',
                  message:
                      'Settle up with friends right after you add transactions.',
                ),
              ],
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              return _SettlementCard(settlement: settlement);
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => ListView(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.warning_amber_outlined,
                title: 'Failed to load settlements',
                message: error.toString(),
                actionLabel: 'Retry',
                onAction: () =>
                    ref.read(settlementsProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementCard extends ConsumerWidget {
  const _SettlementCard({required this.settlement});

  final Settlement settlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();

    final isIncoming =
        settlement.status != 'completed' && settlement.paymentLink != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isIncoming
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.secondaryContainer,
                child: Icon(
                  isIncoming
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncoming
                          ? '${settlement.toUser} should pay you'
                          : 'You paid ${settlement.toUser}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Created on ${DateFormat.yMMMd().format(settlement.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _statusColor(
                    context,
                    settlement.status,
                  ).withOpacity(0.16),
                ),
                child: Text(
                  settlement.status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(context, settlement.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                currency.format(settlement.amount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (settlement.paymentLink != null)
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final link = settlement.paymentLink;
                    if (link == null) return;
                    await Clipboard.setData(
                      ClipboardData(text: link),
                    );
                    AppSnackBar.showSuccess(
                      context,
                      'Payment link copied to clipboard',
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(
                    settlement.status == 'completed'
                        ? 'View receipt'
                        : 'Pay now',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    return switch (status) {
      'pending' => theme.colorScheme.primary,
      'completed' => theme.colorScheme.tertiary,
      'cancelled' => theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }
}

