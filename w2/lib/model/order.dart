import 'menu_item.dart';
import 'table.dart';

enum OrderStatus { open, closed }

class Order {
  final String id;
  final Table table;
  final DateTime createdAt;
  OrderStatus status = OrderStatus.open;
  final List<MenuItem> items = [];

  Order({required this.id, required this.table, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  void addItem(MenuItem item) {
    if (status == OrderStatus.closed) {
      throw Exception('Cannot add items to a closed order');
    }
    items.add(item);
  }

  double get total => items.fold(0.0, (sum, item) => sum + item.price);
}
