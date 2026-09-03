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

class Festival {
  List<Performance> performances = [];

  int get totalPerformances => performances.length;

  void addPerformance(Performance p) {
    performances.add(p);
  }

  List<Performance> performancesForStage(String stage) {
    return performances.where((p) => p.stage == stage).toList();
  }

  List<Performance> findArtistPerformances(String artistName) {
    return performances.where((p) => p.artist.name == artistName).toList();
  }

  Map<String, List<Performance>> groupByStage() {
    Map<String, List<Performance>> groups = {};
    for (Performance p in performances) {
      List<Performance>? list = groups[p.stage];
      if (list == null) {
        list = [];
        groups[p.stage] = list;
      }
      list.add(p);
    }
    return groups;
  }

  void printSummary() {
    print('Total performances: $totalPerformances');
    Map<String, List<Performance>> groups = groupByStage();
    groups.forEach((stage, list) {
      print('$stage: ${list.length} performance(s)');
    });
  }
}

void main() {
  Festival f = Festival();

  Artist a1 = Artist(name: 'DJ Nova', genre: 'Electro');
  Artist a2 = Artist(name: 'The Waves', genre: 'Rock');
  Artist a3 = Artist(name: 'Luna', genre: 'Pop');

  f.addPerformance(
    Performance(artist: a1, stage: 'Stage A', start: 19.0, end: 20.0),
  );
  f.addPerformance(
    Performance(artist: a2, stage: 'Stage B', start: 19.5, end: 20.5),
  );
  f.addPerformance(
    Performance(artist: a3, stage: 'Stage A', start: 20.0, end: 21.0),
  );

  print('\n Performances on Stage A ');
  for (Performance p in f.performancesForStage('Stage A')) {
    print(p);
  }

  print('\n Find artist "DJ Nova" ');
  for (Performance p in f.findArtistPerformances('DJ Nova')) {
    print(p);
  }

  print('\n Summary ');
  f.printSummary();
}
