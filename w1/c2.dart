class Artist {
  final String name;
  final String? genre;

  Artist({required this.name, this.genre});

  @override
  String toString() {
    if (genre != null) {
      return '$name ($genre)';
    } else {
      return name;
    }
  }
}

class Performance {
  final Artist artist;
  final String stage;
  final double start;
  final double end;

  Performance({
    required this.artist,
    required this.stage,
    required this.start,
    required this.end,
  });

  double get duration => end - start;

  @override
  String toString() => '$start-$end  $stage  $artist';
}

class ScheduleConfig {
  final double? gap;
  final int? maxCount;
  final bool allowOverlap;
  final List<String>? stages;

  ScheduleConfig({
    this.gap,
    this.maxCount,
    this.allowOverlap = false,
    this.stages,
  });
}

class Festival {
  final ScheduleConfig config;
  List<Performance> performances = [];

  Festival(this.config);

  int get totalPerformances => performances.length;

  bool overlaps(Performance a, Performance b) {
    return a.start < b.end && b.start < a.end;
  }

  bool addPerformance(Performance p) {
    if (config.maxCount != null && performances.length >= config.maxCount!) {
      print('Rejected: max performances reached.');
      return false;
    }

    if (config.stages != null && !config.stages!.contains(p.stage)) {
      print('Rejected: stage is not allowed.');
      return false;
    }

    for (Performance existing in performances) {
      if (existing.stage != p.stage) {
        continue;
      }

      if (overlaps(p, existing) && !config.allowOverlap) {
        print('Rejected: conflicts with $existing');
        return false;
      }

      if (!overlaps(p, existing) && config.gap != null) {
        double actualGap;
        if (p.start >= existing.end) {
          actualGap = p.start - existing.end;
        } else {
          actualGap = existing.start - p.end;
        }

        if (actualGap < config.gap!) {
          print('Rejected: not enough gap around $existing');
          return false;
        }
      }
    }

    performances.add(p);
    return true;
  }

  List<Performance> performancesForStage(String stage) {
    List<Performance> result = [];
    for (Performance p in performances) {
      if (p.stage == stage) {
        result.add(p);
      }
    }
    return result;
  }

  List<Performance> findArtistPerformances(String artistName) {
    List<Performance> result = [];
    for (Performance p in performances) {
      if (p.artist.name == artistName) {
        result.add(p);
      }
    }
    return result;
  }

  Map<String, List<Performance>> groupByStage() {
    Map<String, List<Performance>> groups = {};
    for (Performance p in performances) {
      if (!groups.containsKey(p.stage)) {
        groups[p.stage] = [];
      }
      groups[p.stage]!.add(p);
    }
    return groups;
  }

  void printSummary() {
    print('Total performances: $totalPerformances');
    Map<String, List<Performance>> groups = groupByStage();
    for (String stage in groups.keys) {
      print('$stage: ${groups[stage]!.length} performance(s)');
    }
  }
}

void main() {
  ScheduleConfig config = ScheduleConfig(
    gap: 0.5,
    maxCount: 10,
    allowOverlap: false,
    stages: ['Stage A', 'Stage B'],
  );

  Festival f = Festival(config);

  Artist a1 = Artist(name: 'DJ Nova', genre: 'Electro');
  Artist a2 = Artist(name: 'The Waves', genre: 'Rock');
  Artist a3 = Artist(name: 'Luna', genre: 'Pop');

  f.addPerformance(
    Performance(artist: a1, stage: 'Stage A', start: 19.0, end: 20.0),
  );

  f.addPerformance(
    Performance(artist: a2, stage: 'Stage B', start: 19.5, end: 20.5),
  );

  print('\n--- Conflict test (same stage, overlapping) ---');
  f.addPerformance(
    Performance(artist: a3, stage: 'Stage A', start: 19.5, end: 20.5),
  );

  print('\n--- Performances on Stage A ---');
  for (Performance p in f.performancesForStage('Stage A')) {
    print(p);
  }

  print('\n--- Find artist "DJ Nova" ---');
  for (Performance p in f.findArtistPerformances('DJ Nova')) {
    print(p);
  }

  print('\n--- Summary ---');
  f.printSummary();
}
