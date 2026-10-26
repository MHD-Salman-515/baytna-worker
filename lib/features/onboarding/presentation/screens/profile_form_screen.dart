import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/onboarding/presentation/bloc/profile_form/profile_form_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Reachable only while her profile is editable (router allow-list).
class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = context.read<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) => getIt<ProfileFormBloc>(param1: worker.profile)..add(const ProfileFormStarted()),
      child: BlocListener<ProfileFormBloc, ProfileFormState>(
        listenWhen: (prev, next) => prev.status != next.status && next.status is ProfileFormSaved,
        listener: (context, state) {
          final saved = (state.status as ProfileFormSaved).profile;
          context.read<WorkerBloc>().add(WorkerProfileChanged(saved));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
          // First time through: straight on to documents. Editing later: back.
          if (!worker.profile.isProfileComplete) {
            context.pushReplacement(AppRoutes.documents);
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.status);
          }
        },
        child: PageScaffold(
          title: context.l10n.profileTitle,
          subtitle: context.l10n.profileSubtitle,
          body: BlocBuilder<ProfileFormBloc, ProfileFormState>(
            buildWhen: (prev, next) => prev.cities != next.cities,
            builder: (context, state) => switch (state.cities) {
              CitiesLoading() => const Center(child: CircularProgressIndicator()),
              CitiesFailed(:final failure) => FailureView(
                failure: failure,
                onRetry: () => context.read<ProfileFormBloc>().add(const ProfileFormStarted(forceRefresh: true)),
              ),
              CitiesLoaded() => const _ProfileForm(),
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<ProfileFormBloc>();
    final initial = bloc.state;

    return BlocBuilder<ProfileFormBloc, ProfileFormState>(
      builder: (context, state) {
        final errors = state.visibleErrors;
        final saving = state.status is ProfileFormSaving;
        final failure = switch (state.status) {
          ProfileFormFailed(:final failure) => failure.message(l10n),
          _ => null,
        };
        String? errorFor(ProfileField f, String message) => errors.contains(f) ? message : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextFormField(
                    key: const ValueKey('profile-bio-ar'),
                    initialValue: initial.bioAr,
                    enabled: !saving,
                    maxLines: 3,
                    maxLength: ProfileFormBloc.maxBioLength,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(labelText: l10n.profileBioAr, hintText: l10n.profileBioHint),
                    onChanged: (v) => bloc.add(ProfileBioArChanged(v)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('profile-bio-en'),
                    initialValue: initial.bioEn,
                    enabled: !saving,
                    maxLines: 3,
                    maxLength: ProfileFormBloc.maxBioLength,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(labelText: l10n.profileBioEn),
                    onChanged: (v) => bloc.add(ProfileBioEnChanged(v)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('profile-years'),
                    initialValue: initial.years,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]')), LengthLimitingTextInputFormatter(2)],
                    decoration: InputDecoration(
                      labelText: l10n.profileYears,
                      errorText: errorFor(ProfileField.years, l10n.profileYearsInvalid),
                    ),
                    onChanged: (v) => bloc.add(ProfileYearsChanged(v)),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.profileLanguages, error: errorFor(ProfileField.languages, l10n.profileLanguagesRequired)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final code in WorkerLanguages.all)
                        FilterChip(
                          key: ValueKey('lang-$code'),
                          label: Text(_languageName(l10n, code)),
                          selected: state.languages.contains(code),
                          onSelected: saving ? null : (_) => bloc.add(ProfileLanguageToggled(code)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.profileCity, error: errorFor(ProfileField.city, l10n.profileCityRequired)),
                  if (state.cityList.isEmpty)
                    Text(l10n.profileNoCities)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final city in state.cityList)
                          ChoiceChip(
                            key: ValueKey('city-${city.id}'),
                            label: Text(context.localize(city.name)),
                            selected: state.cityId == city.id,
                            onSelected: saving ? null : (_) => bloc.add(ProfileCityChanged(city.id)),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.profileAreas, error: errorFor(ProfileField.serviceAreas, l10n.profileAreasRequired)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final city in state.cityList)
                        FilterChip(
                          key: ValueKey('area-${city.id}'),
                          label: Text(context.localize(city.name)),
                          selected: state.serviceAreas.contains(city.id),
                          onSelected: saving ? null : (_) => bloc.add(ProfileAreaToggled(city.id)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (failure != null) ...[
              Text(failure, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
            ],
            PrimaryButton(
              key: const ValueKey('profile-save'),
              label: l10n.profileSave,
              loading: saving,
              onPressed: () => bloc.add(const ProfileFormSubmitted()),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.error});

  final String text;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (error != null)
            Text(error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
      ),
    );
  }
}

String _languageName(AppLocalizations l10n, String code) => switch (code) {
  'ar' => l10n.languageAr,
  'ku' => l10n.languageKu,
  'en' => l10n.languageEn,
  'tr' => l10n.languageTr,
  'fr' => l10n.languageFr,
  _ => code,
};
