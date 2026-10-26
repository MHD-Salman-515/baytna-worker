import 'package:baytna_worker/core/network/json.dart';
import 'package:equatable/equatable.dart';

/// The `meta` object that paginated endpoints send next to `data`.
class PageMeta extends Equatable {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Missing or malformed meta degrades to "one page holding everything".
  factory PageMeta.fromJson(Object? json, {required int itemCount}) {
    final m = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    int read(String key, int fallback) => (m[key] as num?)?.toInt() ?? fallback;
    return PageMeta(
      page: read('page', 1),
      limit: read('limit', itemCount),
      total: read('total', itemCount),
      totalPages: read('totalPages', 1),
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNext => page < totalPages;

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}

class Paged<T> extends Equatable {
  const Paged({required this.items, required this.meta});

  final List<T> items;
  final PageMeta meta;

  @override
  List<Object?> get props => [items, meta];
}

typedef ItemDecoder<T> = T Function(Json json);
