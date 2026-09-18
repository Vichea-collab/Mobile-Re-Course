class Restaurant {
  final String name;
  final int openingHour;
  final int closingHour;
  final int defaultDurationMinutes;
  final int maxLateMinutes;

  Restaurant({
    required this.name,
    required this.openingHour,
    required this.closingHour,
    required this.defaultDurationMinutes,
    required this.maxLateMinutes,
  });
}
