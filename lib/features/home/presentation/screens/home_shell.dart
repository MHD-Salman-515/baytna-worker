import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The approved worker's app: jobs, her work settings, her wallet. The router
/// only shows this to APPROVED workers.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            key: const ValueKey('tab-jobs'),
            icon: const Icon(Icons.work_outline_rounded),
            selectedIcon: const Icon(Icons.work_rounded),
            label: l10n.tabJobs,
          ),
          NavigationDestination(
            key: const ValueKey('tab-work'),
            icon: const Icon(Icons.tune_rounded),
            label: l10n.tabWork,
          ),
          NavigationDestination(
            key: const ValueKey('tab-wallet'),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.tabWallet,
          ),
        ],
      ),
    );
  }
}
