const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

extension HistoryTimestampFormatting on DateTime {
  String get formattedHistoryTimestamp {
    final local = toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthAbbreviations[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month ${local.year}, $hour:$minute';
  }
}
