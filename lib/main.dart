import 'dart:async';

import 'package:baytna_worker/app.dart';
import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/documents/data/datasources/platform_document_picker.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Restore the language before the first frame to avoid an ar→en flash.
  await getIt<LocaleCubit>().load();
  // Created before the session resolves, so it sees AuthBloc's first state.
  getIt<WorkerBloc>();
  getIt<AuthBloc>().add(const AuthStarted());
  // Remove ID photos a previous run may have left in the picker cache.
  unawaited(PlatformDocumentPicker.purgeTemporaryFiles());
  runApp(const BaytnaApp());
}
