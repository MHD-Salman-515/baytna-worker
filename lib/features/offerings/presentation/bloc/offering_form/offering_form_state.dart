part of 'offering_form_bloc.dart';

class TierDraft extends Equatable {
  const TierDraft({this.maxRooms = '', this.price = ''});

  final String maxRooms;
  final String price;

  @override
  List<Object?> get props => [maxRooms, price];
}

final class OfferingFormState extends Equatable {
  const OfferingFormState({
    required this.countryId,
    this.offeringId,
    this.services = const [],
    this.selectable = const [],
    this.rules = const [],
    this.serviceId,
    this.pricingType,
    this.amount = '',
    this.minHours = '2',
    this.tiers = const [TierDraft()],
    this.currency = '',
    this.isActive = true,
    this.status = const FormLoading(),
  });

  final String countryId;

  /// Null when adding.
  final String? offeringId;
  final List<Service> services;

  /// Services she may choose from (those she doesn't offer yet, when adding).
  final List<Service> selectable;
  final List<PricingRule> rules;
  final String? serviceId;
  final PricingType? pricingType;

  /// As typed: the hourly rate or the fixed price.
  final String amount;
  final String minHours;
  final List<TierDraft> tiers;

  /// Her country's on a new offering; the stored one when editing. Fixed at
  /// creation either way, so the form shows it and never sends it.
  final String currency;
  final bool isActive;
  final OfferingFormStatus status;

  bool get isEditing => offeringId != null;

  Service? get service => services.where((s) => s.id == serviceId).firstOrNull;

  /// Only these may be chosen.
  List<PricingType> get allowedTypes =>
      service?.allowedPricingTypes.where((t) => t != PricingType.unknown).toList() ?? const [];

  /// The range to show BEFORE she types.
  PricingRule? get rule => rules
      .where((r) => r.serviceId == serviceId && r.pricingType == pricingType)
      .firstOrNull;

  /// Null until the numbers parse.
  OfferingPrice? get parsedPrice {
    int? number(String text) => int.tryParse(PhoneNumber.asciiDigits(text.trim()));
    switch (pricingType) {
      case PricingType.hourly:
        final rate = number(amount);
        final hours = number(minHours);
        return rate == null || hours == null ? null : HourlyPrice(rate: rate, minHours: hours);
      case PricingType.fixed:
        final price = number(amount);
        return price == null ? null : FixedPrice(price);
      case PricingType.bySize:
        final parsed = <SizeTier>[];
        for (final t in tiers) {
          final rooms = number(t.maxRooms);
          final price = number(t.price);
          if (rooms == null || price == null) return null;
          parsed.add(SizeTier(maxRooms: rooms, price: price));
        }
        return BySizePrice(parsed);
      case PricingType.unknown || null:
        return null;
    }
  }

  Set<OfferingError> get errors {
    final price = parsedPrice;
    return price == null ? const {OfferingError.priceMissing} : OfferingValidator.validate(price, rule);
  }

  bool get canSave => serviceId != null && pricingType != null;

  OfferingFormState prefilledFrom(Offering o) {
    final price = o.price;
    return copyWith(
      serviceId: () => o.serviceId,
      pricingType: price.type,
      currency: o.currency,
      isActive: o.isActive,
      amount: switch (price) {
        HourlyPrice(:final rate) => '$rate',
        FixedPrice(price: final p) => '$p',
        BySizePrice() => '',
      },
      minHours: price is HourlyPrice ? '${price.minHours}' : null,
      tiers: price is BySizePrice
          ? [for (final t in price.tiers) TierDraft(maxRooms: '${t.maxRooms}', price: '${t.price}')]
          : null,
    );
  }

  OfferingFormState copyWith({
    List<Service>? services,
    List<Service>? selectable,
    List<PricingRule>? rules,
    String? Function()? serviceId,
    PricingType? pricingType,
    String? amount,
    String? minHours,
    List<TierDraft>? tiers,
    String? currency,
    bool? isActive,
    OfferingFormStatus? status,
  }) => OfferingFormState(
    countryId: countryId,
    offeringId: offeringId,
    services: services ?? this.services,
    selectable: selectable ?? this.selectable,
    rules: rules ?? this.rules,
    serviceId: serviceId != null ? serviceId() : this.serviceId,
    pricingType: pricingType ?? this.pricingType,
    amount: amount ?? this.amount,
    minHours: minHours ?? this.minHours,
    tiers: tiers ?? this.tiers,
    currency: currency ?? this.currency,
    isActive: isActive ?? this.isActive,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    countryId,
    offeringId,
    services,
    selectable,
    rules,
    serviceId,
    pricingType,
    amount,
    minHours,
    tiers,
    currency,
    isActive,
    status,
  ];
}

sealed class OfferingFormStatus extends Equatable {
  const OfferingFormStatus();

  @override
  List<Object?> get props => [];
}

final class FormLoading extends OfferingFormStatus {
  const FormLoading();
}

final class FormLoadFailed extends OfferingFormStatus {
  const FormLoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class FormEditing extends OfferingFormStatus {
  const FormEditing();
}

/// Errors show only after a save attempt.
final class FormInvalid extends OfferingFormStatus {
  const FormInvalid(this.errors);

  final Set<OfferingError> errors;

  @override
  List<Object?> get props => [errors];
}

final class FormSaving extends OfferingFormStatus {
  const FormSaving();
}

final class FormSaveFailed extends OfferingFormStatus {
  const FormSaveFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Saved or deleted; the screen closes.
final class FormDone extends OfferingFormStatus {
  const FormDone();
}
