import 'package:flutter/material.dart';

class DateRangeSelector extends StatelessWidget {
  final String currentPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onPeriodChanged;
  final Function(DateTime, DateTime) onCustomRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.currentPeriod,
    this.startDate,
    this.endDate,
    required this.onPeriodChanged,
    required this.onCustomRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PeriodChip(
                    label: 'Today',
                    isSelected: currentPeriod == 'today',
                    onTap: () => onPeriodChanged('today'),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Week',
                    isSelected: currentPeriod == 'week',
                    onTap: () => onPeriodChanged('week'),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Month',
                    isSelected: currentPeriod == 'month',
                    onTap: () => onPeriodChanged('month'),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Year',
                    isSelected: currentPeriod == 'year',
                    onTap: () => onPeriodChanged('year'),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Custom',
                    isSelected: currentPeriod == 'custom',
                    onTap: () => _showCustomDateRangePicker(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      onCustomRangeSelected(picked.start, picked.end);
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
