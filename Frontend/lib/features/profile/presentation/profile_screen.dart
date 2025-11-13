import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/widgets/app_snackbar.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user?.initials ?? 'U',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                user?.fullName ?? 'SplitBill user',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: theme.brightness == Brightness.dark,
                onChanged: (_) {
                  AppSnackBar.showError(context,
                      'Theme switching is managed by system settings.');
                },
                title: const Text('Dark mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                subtitle:
                    const Text('Manage reminders and payment updates'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Privacy policy'),
                onTap: () {},
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of use'),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: authState.isLoading
              ? null
              : () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!mounted) return;
                  AppSnackBar.showSuccess(context, 'Signed out');
                },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
        if (_info != null) ...[
          const SizedBox(height: 24),
          Center(
            child: Text(
              'App version ${_info!.version} (${_info!.buildNumber})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}


