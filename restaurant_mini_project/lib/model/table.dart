enum TableLocation { indoor, outdoor, window, bar, privateRoom }

enum TableStatus { available, occupied, outOfService }

class Table {
  final int id;
  final int capacity;
  final TableLocation location;
  TableStatus status = TableStatus.available;

  Table({required this.id, required this.capacity, required this.location});
}
