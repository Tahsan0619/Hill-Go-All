/// Laravel-style paginated list response.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<T> items;
  final int page;
  final bool hasMore;

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  /// Parses a Laravel paginator JSON body (`data` + `meta` or top-level page fields).
  static PagedResult<T> parse<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapItem,
  ) {
    final rows = json['data'] as List? ?? [];
    final items = rows
        .whereType<Map<String, dynamic>>()
        .map(mapItem)
        .toList();

    final meta = json['meta'] as Map<String, dynamic>?;
    if (meta != null) {
      final currentPage = _asInt(meta['current_page'], 1);
      final lastPage = _asInt(meta['last_page'], currentPage);
      return PagedResult(
        items: items,
        page: currentPage,
        hasMore: currentPage < lastPage,
      );
    }

    if (json['current_page'] != null) {
      final currentPage = _asInt(json['current_page'], 1);
      final lastPage = _asInt(json['last_page'], currentPage);
      return PagedResult(
        items: items,
        page: currentPage,
        hasMore: currentPage < lastPage,
      );
    }

    if (json.containsKey('next_page_url')) {
      return PagedResult(
        items: items,
        page: _asInt(json['current_page'], 1),
        hasMore: json['next_page_url'] != null,
      );
    }

    return PagedResult(items: items, page: 1, hasMore: false);
  }
}
