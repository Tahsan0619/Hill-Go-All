import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Filter options used on the Search screen bottom sheet.
class SearchFilters {
  const SearchFilters({
    this.serviceType = 'All',
    this.sortBy = 'Recommended',
    this.openNowOnly = false,
  });

  final String serviceType;
  final String sortBy;
  final bool openNowOnly;

  static const serviceTypes = [
    'All',
    'Ride',
    'Food',
    'Market',
    'Parcel',
  ];

  static const sortOptions = [
    'Recommended',
    'Nearest',
    'Top rated',
    'Fastest delivery',
  ];

  SearchFilters copyWith({
    String? serviceType,
    String? sortBy,
    bool? openNowOnly,
  }) {
    return SearchFilters(
      serviceType: serviceType ?? this.serviceType,
      sortBy: sortBy ?? this.sortBy,
      openNowOnly: openNowOnly ?? this.openNowOnly,
    );
  }

  bool get hasActiveFilters =>
      serviceType != 'All' || sortBy != 'Recommended' || openNowOnly;
}

Future<SearchFilters?> showSearchFilterSheet(
  BuildContext context, {
  required SearchFilters initial,
}) {
  return showModalBottomSheet<SearchFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _SearchFilterSheet(initial: initial),
  );
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({required this.initial});

  final SearchFilters initial;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late SearchFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Filters',
                style: textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _filters = const SearchFilters());
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Service type',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SearchFilters.serviceTypes.map((type) {
              final selected = _filters.serviceType == type;
              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _filters = _filters.copyWith(serviceType: type)),
                selectedColor: AppColors.primaryNavy,
                backgroundColor: AppColors.white,
                side: BorderSide(
                  color: selected ? AppColors.primaryNavy : AppColors.cardBorder,
                ),
                labelStyle: TextStyle(
                  color: selected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort by',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...SearchFilters.sortOptions.map((option) {
            return RadioListTile<String>(
              value: option,
              groupValue: _filters.sortBy,
              activeColor: AppColors.primaryNavy,
              contentPadding: EdgeInsets.zero,
              title: Text(option, style: textTheme.bodyMedium),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filters = _filters.copyWith(sortBy: value));
                }
              },
            );
          }),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open now only'),
            value: _filters.openNowOnly,
            activeColor: AppColors.primaryNavy,
            onChanged: (value) =>
                setState(() => _filters = _filters.copyWith(openNowOnly: value)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_filters),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
