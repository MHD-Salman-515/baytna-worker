import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:flutter/material.dart';

extension PricingTypeLabel on PricingType {
  String label(AppLocalizations l10n) => switch (this) {
    PricingType.hourly => l10n.pricingHourly,
    PricingType.bySize => l10n.pricingBySize,
    PricingType.fixed => l10n.pricingFixed,
    PricingType.unknown => '',
  };

  String explain(AppLocalizations l10n) => switch (this) {
    PricingType.hourly => l10n.pricingHourlyExplain,
    PricingType.bySize => l10n.pricingBySizeExplain,
    PricingType.fixed => l10n.pricingFixedExplain,
    PricingType.unknown => '',
  };
}

IconData serviceIcon(String key) => switch (key) {
  'CLEANING' => Icons.cleaning_services_rounded,
  'COOKING' => Icons.soup_kitchen_rounded,
  'IRONING' => Icons.iron_rounded,
  _ => Icons.home_repair_service_rounded,
};

/// One line describing what she charges.
String priceSummary(AppLocalizations l10n, Offering offering, String language) {
  String money(int amount) => formatMoney(Money(amount, offering.currency), language);
  return switch (offering.price) {
    HourlyPrice(:final rate, :final minHours) => l10n.priceSummaryHourly(money(rate), minHours),
    FixedPrice(:final price) => l10n.priceSummaryFixed(money(price)),
    BySizePrice(:final tiers) => tiers.isEmpty
        ? ''
        : l10n.priceSummaryBySize(money(tiers.first.price), money(tiers.last.price), tiers.last.maxRooms),
  };
}
