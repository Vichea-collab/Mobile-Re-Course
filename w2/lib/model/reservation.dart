import 'customer.dart';
import 'table.dart';

class Reservation {
  final String id;
  final Customer customer;
  final Table table;
  final DateTime dateTime;

  Reservation({
    required this.id,
    required this.customer,
    required this.table,
    required this.dateTime,
  });
}
