class Artist {
  final String name;
  final String genre;

  const Artist({
    required this.name,
    required this.genre,
  });
}

class Performance {
  final Artist artist;
  final String stage;
  final DateTime start;
  final DateTime end;

  Performance({
    required this.artist,
    required this.stage,
    required this.start,
    required this.end,
  });
}

class ScheduleRules {
  final Duration minGapBetweenPerformances;
  final int? maxPerformances;
  final bool allowOverlap;
  final List<String>? allowedStages;

  const ScheduleRules({
    this.minGapBetweenPerformances = Duration.zero,
    this.maxPerformances,
    this.allowOverlap = false,
    this.allowedStages,
  });
}

class FestivalSchedule {
  final String festivalName;
  final ScheduleRules rules;
  final Map<String, List<Performance>> performancesByStage;
}
