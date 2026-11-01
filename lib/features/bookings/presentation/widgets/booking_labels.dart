import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/time/country_time.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/booking_failures.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/documents/presentation/widgets/document_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BookingStatusLabel on BookingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    BookingStatus.searching => l10n.bookingStatusSearching,
    BookingStatus.pendingWorker => l10n.bookingStatusPending,
    BookingStatus.accepted => l10n.bookingStatusAccepted,
    BookingStatus.onTheWay => l10n.bookingStatusOnTheWay,
    BookingStatus.arrived => l10n.bookingStatusArrived,
    BookingStatus.inProgress => l10n.bookingStatusInProgress,
    BookingStatus.completed => l10n.bookingStatusCompleted,
    BookingStatus.rejected => l10n.bookingStatusRejected,
    BookingStatus.cancelled => l10n.bookingStatusCancelled,
    BookingStatus.expired => l10n.bookingStatusExpired,
    BookingStatus.noWorkerFound || BookingStatus.unknown => l10n.bookingStatusUnknown,
    BookingStatus.noShow => l10n.bookingStatusNoShow,
  };
}

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({required this.status, super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, fg, bg) = switch (status) {
      BookingStatus.pendingWorker => (Icons.notifications_active_rounded, scheme.onSecondaryContainer, scheme.secondaryContainer),
      BookingStatus.accepted ||
      BookingStatus.onTheWay ||
      BookingStatus.arrived ||
      BookingStatus.inProgress => (Icons.directions_walk_rounded, scheme.onPrimaryContainer, scheme.primaryContainer),
      BookingStatus.completed => (Icons.check_circle_rounded, scheme.onPrimaryContainer, scheme.primaryContainer),
      BookingStatus.cancelled ||
      BookingStatus.rejected ||
      BookingStatus.noShow => (Icons.cancel_rounded, scheme.onErrorContainer, scheme.errorContainer),
      _ => (Icons.schedule_rounded, scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
    };
    return StatusChip(label: status.label(context.l10n), icon: icon, foreground: fg, background: bg);
  }
}

/// "Sat, 7 Nov · 10:00", on the COUNTRY's clock.
String formatBookingTime(BuildContext context, DateTime instant, CountryTime time) {
  final locale = Localizations.localeOf(context).languageCode;
  final local = time.local(instant);
  return '${DateFormat.MMMEd(locale).format(local)} · ${DateFormat.Hm('en').format(local)}';
}

/// "2 h 14 min".
String formatDuration(AppLocalizations l10n, Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return l10n.durationMinutes(minutes);
  return minutes == 0 ? l10n.durationHours(hours) : l10n.durationHoursMinutes(hours, minutes);
}

/// Where the job is, as honestly as can be said before the pin is revealed.
String placeSummary(BuildContext context, Booking booking, BookingContext ctx, String? homeCityId) {
  final l10n = context.l10n;
  final city = ctx.city(booking.cityId);
  final name = city == null ? '' : context.localize(city.name);
  if (booking.cityId == homeCityId) return l10n.bookingPlaceYourCity(name);
  final km = ctx.kmBetweenCities(homeCityId, booking.cityId);
  return km == null ? name : l10n.bookingPlaceOtherCity(name, km);
}

String bookingFailureMessage(Failure failure, AppLocalizations l10n) => switch (failure) {
  IllegalTransition(current: BookingStatus.expired) => l10n.bookingErrorExpired,
  IllegalTransition(current: BookingStatus.cancelled) => l10n.bookingErrorCancelled,
  IllegalTransition(current: BookingStatus.completed) => l10n.bookingErrorCompleted,
  IllegalTransition() => l10n.bookingErrorStale,
  NotAllowedToAcceptWork() => l10n.bookingErrorGate,
  BookingClash() => l10n.bookingErrorClash,
  JobStepRefused() => l10n.bookingErrorRefused,
  BookingNotFound() => l10n.bookingErrorNotFound,
  _ => failure.message(l10n),
};
