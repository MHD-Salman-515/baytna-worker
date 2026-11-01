import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/time/country_time.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';
import 'package:baytna_worker/features/availability/presentation/bloc/availability/availability_bloc.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

/// When she works, each week, plus exceptions. Times are on her COUNTRY's
/// clock, which the screen states and shows, because the phone's may differ.
class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = context.read<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => getIt<AvailabilityBloc>(param1: worker.profile.countryId)..add(const AvailabilityStarted()),
      child: BlocListener<AvailabilityBloc, AvailabilityState>(
        listenWhen: (prev, next) => prev.status != next.status,
        listener: (context, state) {
          final message = switch (state.status) {
            ScheduleSavedOk() => l10n.scheduleSaved,
            ScheduleInvalid() => l10n.scheduleInvalid,
            ScheduleSaveFailed(failure: final Failure f) when f is ValidationFailure => l10n.scheduleInvalid,
            ScheduleSaveFailed(:final failure) => failure.message(l10n),
            _ => null,
          };
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: PageScaffold(
          title: l10n.scheduleTitle,
          body: BlocBuilder<AvailabilityBloc, AvailabilityState>(
            buildWhen: (a, b) => a.status != b.status || a.draft != b.draft,
            builder: (context, state) => switch (state.status) {
              ScheduleLoading() => const Center(child: CircularProgressIndicator()),
              ScheduleLoadFailed(:final failure) => FailureView(
                failure: failure,
                onRetry: () => context.read<AvailabilityBloc>().add(const AvailabilityStarted()),
              ),
              _ => _Editor(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.state});

  final AvailabilityState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<AvailabilityBloc>();
    final time = CountryTime(state.timezone);
    final now = getIt<Clock>().now();
    final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday, like the backend
    final today = time.dateKey(now);
    final upcoming = state.draft.overrides.where((o) => o.date.compareTo(today) >= 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.scheduleTimezone(
                      ltrIsolate(state.timezone),
                      ltrIsolate(DateFormat.Hm('en').format(time.local(now))),
                    ),
                    key: const ValueKey('schedule-timezone'),
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < 7; i++) _DayRow(day: (firstDay + i) % 7, ranges: state.draft.days[(firstDay + i) % 7] ?? const []),
              const SizedBox(height: 16),
              Text(l10n.scheduleExceptions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text(l10n.scheduleExceptionsHint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              for (final o in upcoming)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(o.type == OverrideType.blocked ? Icons.event_busy_rounded : Icons.more_time_rounded),
                  title: Text(ltrIsolate(o.date)),
                  subtitle: Text(
                    o.type == OverrideType.blocked
                        ? l10n.scheduleBlocked
                        : l10n.scheduleExtra(ltrIsolate('${o.range?.start}–${o.range?.end}')),
                  ),
                  trailing: IconButton(
                    tooltip: l10n.documentDiscard,
                    onPressed: () => bloc.add(AvailabilityOverrideRemoved(o)),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('add-blocked-day'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () => unawaited(_addException(context, time, now, OverrideType.blocked)),
                      icon: const Icon(Icons.event_busy_rounded, size: 20),
                      label: Text(l10n.scheduleAddBlocked),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('add-extra-hours'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () => unawaited(_addException(context, time, now, OverrideType.extra)),
                      icon: const Icon(Icons.more_time_rounded, size: 20),
                      label: Text(l10n.scheduleAddExtra),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        PrimaryButton(
          key: const ValueKey('schedule-save'),
          label: l10n.scheduleSave,
          loading: state.status is ScheduleSaving,
          onPressed: state.hasChanges ? () => bloc.add(const AvailabilitySaved()) : null,
        ),
      ],
    );
  }

  Future<void> _addException(BuildContext context, CountryTime time, DateTime now, OverrideType type) async {
    final bloc = context.read<AvailabilityBloc>();
    final today = time.local(now);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year, today.month, today.day + 1),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked == null || !context.mounted) return;
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${picked.year}-${two(picked.month)}-${two(picked.day)}';
    if (type == OverrideType.blocked) {
      bloc.add(AvailabilityOverrideAdded(DateOverride(date: date, type: type)));
      return;
    }
    final start = await _pickTime(context, '09:00');
    if (start == null || !context.mounted) return;
    final end = await _pickTime(context, '17:00');
    if (end == null) return;
    bloc.add(AvailabilityOverrideAdded(DateOverride(date: date, type: type, range: TimeRange(start: start, end: end))));
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.ranges});

  final int day;
  final List<TimeRange> ranges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<AvailabilityBloc>();
    final locale = Localizations.localeOf(context).languageCode;
    // 1 Jan 2023 was a Sunday, so day 0 lands on Sunday.
    final name = DateFormat.EEEE(locale).format(DateTime.utc(2023, 1, 1 + day));
    final error = ScheduleValidator.dayError(ranges);

    return Padding(
      key: ValueKey('day-$day'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              if (ranges.isEmpty) Text(l10n.scheduleDayOff, style: theme.textTheme.bodySmall),
              Switch(
                key: ValueKey('day-$day-switch'),
                value: ranges.isNotEmpty,
                onChanged: (v) => bloc.add(AvailabilityDayToggled(day, enabled: v)),
              ),
            ],
          ),
          for (final (i, range) in ranges.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Directionality(
                textDirection: TextDirection.ltr, // a time range reads left to right
                child: Row(
                  children: [
                    Expanded(child: _TimeButton(value: range.start, onPicked: (t) => bloc.add(AvailabilityRangeChanged(day, i, TimeRange(start: t, end: range.end))))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('–')),
                    Expanded(child: _TimeButton(value: range.end, onPicked: (t) => bloc.add(AvailabilityRangeChanged(day, i, TimeRange(start: range.start, end: t))))),
                    IconButton(
                      tooltip: l10n.documentDiscard,
                      onPressed: () => bloc.add(AvailabilityRangeRemoved(day, i)),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          if (error != null)
            Text(
              error == ScheduleError.overlap ? l10n.scheduleOverlap : l10n.scheduleRangeInvalid,
              key: ValueKey('day-$day-error'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          if (ranges.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => bloc.add(AvailabilityRangeAdded(day)),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.scheduleAddRange),
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.value, required this.onPicked});

  final String value;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
      onPressed: () async {
        final picked = await _pickTime(context, value);
        if (picked != null) onPicked(picked);
      },
      child: Text(value),
    );
  }
}

/// `HH:mm` from a 24-hour picker, whatever the phone's clock format.
Future<String?> _pickTime(BuildContext context, String initial) async {
  final parts = initial.split(':');
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (picked == null) return null;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(picked.hour)}:${two(picked.minute)}';
}
