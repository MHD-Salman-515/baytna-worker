import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:baytna_worker/core/network/server_status.dart';
import 'package:baytna_worker/core/router/app_router.dart';
import 'package:baytna_worker/core/theme/app_theme.dart';
import 'package:baytna_worker/core/widgets/waking_up_banner.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class BaytnaApp extends StatelessWidget {
  const BaytnaApp({super.key});

  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<WorkerBloc>()),
        BlocProvider.value(value: getIt<LocaleCubit>()),
      ],
      child: BlocConsumer<LocaleCubit, Locale>(
        // Keep the server's copy of the language in sync while signed in.
        listener: (context, locale) =>
            context.read<AuthBloc>().add(AuthLocaleChanged(locale.languageCode)),
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Arabic by default → RTL by default; Flutter derives the text
          // direction from the locale.
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scaffoldMessengerKey: _messengerKey,
          routerConfig: getIt<AppRouter>().config,
          builder: (context, child) => _AppShell(messengerKey: _messengerKey, child: child!),
        ),
      ),
    );
  }
}

/// App-wide overlays that need localization: the waking-up banner and the
/// "session ended" notice.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.messengerKey, required this.child});

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, next) => next is AuthUnauthenticated && next.sessionExpired,
      listener: (context, _) => messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(context.l10n.sessionExpired)),
      ),
      child: WakingUpBanner(status: getIt<ServerStatus>(), child: child),
    );
  }
}
