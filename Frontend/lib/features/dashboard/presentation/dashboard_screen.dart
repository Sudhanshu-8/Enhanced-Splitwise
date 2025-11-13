import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_card.dart';
import '../controllers/dashboard_controller.dart';
import '../models/group_overview.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: dashboardState.when(
        data: (groups) => _DashboardContent(groups: groups),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ListView(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EmptyState(
                icon: Icons.warning_amber_rounded,
                title: 'Something went wrong',
                message: error.toString(),
                actionLabel: 'Try again',
                onAction: () =>
                    ref.read(dashboardProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.groups});

  final List<GroupOverview> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();

    final youAreOwed = groups
        .where((g) => g.totalBalance > 0)
        .fold<double>(0, (prev, g) => prev + g.totalBalance);
    final youOwe = groups
        .where((g) => g.totalBalance < 0)
        .fold<double>(0, (prev, g) => prev + g.totalBalance.abs());

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'You are owed',
                value: currency.format(youAreOwed),
                icon: Icons.trending_up_rounded,
                tone: StatTone.positive,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'You owe',
                value: currency.format(youOwe),
                icon: Icons.trending_down_rounded,
                tone: StatTone.negative,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Groups',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          const EmptyState(
            icon: Icons.group_add_outlined,
            title: 'No groups yet',
            message: 'Create a group to start tracking shared expenses.',
          )
        else
          ...groups.map(
            (group) => _GroupCard(
              group: group,
              format: currency,
            ),
          ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.format,
  });

  final GroupOverview group;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balanceColor = group.totalBalance >= 0
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final balancePrefix = group.totalBalance >= 0 ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.35),
                    ),
                    child: Icon(
                      Icons.groups_3_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.members.length} members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (group.description != null && group.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    group.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: balanceColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(
                      group.totalBalance >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: balanceColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        group.totalBalance >= 0
                            ? 'You are owed'
                            : 'You owe',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$balancePrefix${format.format(group.totalBalance.abs())}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


