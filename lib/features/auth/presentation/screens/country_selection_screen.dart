import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/countries/countries_bloc.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CountrySelectionScreen extends StatelessWidget {
  const CountrySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CountriesBloc>()..add(const CountriesRequested()),
      child: PageScaffold(
        title: context.l10n.countrySelectTitle,
        subtitle: context.l10n.countrySelectSubtitle,
        body: BlocBuilder<CountriesBloc, CountriesState>(
          builder: (context, state) => switch (state) {
            CountriesLoading() => const Center(child: CircularProgressIndicator()),
            CountriesFailure(:final failure) => FailureView(
              failure: failure,
              onRetry: () => context.read<CountriesBloc>().add(
                const CountriesRequested(forceRefresh: true),
              ),
            ),
            CountriesLoaded(countries: []) => Center(child: Text(context.l10n.countriesEmpty)),
            CountriesLoaded(:final countries) => ListView.separated(
              itemCount: countries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _CountryTile(country: countries[i]),
            ),
          },
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        key: ValueKey('country-${country.code}'),
        onTap: () => context.push(AppRoutes.phoneFor(country.id)),
        leading: Text(country.flag, style: const TextStyle(fontSize: 30)),
        title: Text(
          context.localize(country.name),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(ltrIsolate('${country.phonePrefix} · ${country.currencyCode}')),
        // chevron_right has matchTextDirection, so it points left in RTL.
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
