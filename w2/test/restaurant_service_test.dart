import 'package:test/test.dart';
import '../lib/model/customer.dart';
import '../lib/model/menu_item.dart';
import '../lib/model/table.dart';
import '../lib/service/restaurant_service.dart';

void main() {
  group('Restaurant service', () {
    late RestaurantService service;

    setUp(() {
      service = RestaurantService();
      service.addTable(table: Table(id: 1, capacity: 4));
      service.addTable(table: Table(id: 2, capacity: 2));
      service.addMenuItem(
        item: MenuItem(id: 'M1', name: 'Margherita Pizza', price: 12.0, category: 'Main'),
      );
      service.addMenuItem(
        item: MenuItem(id: 'M2', name: 'Tiramisu', price: 6.5, category: 'Dessert'),
      );
      service.registerCustomer(
        customer: Customer(id: 'C1', name: 'Alice', phone: '555-0100'),
      );
    });

    test('creates an order for an available table', () {
      service.createOrder(orderId: 'O1', tableId: 1);

      final table = service.tables.firstWhere((t) => t.id == 1);

      expect(service.orders.length, 1);
      expect(table.isOccupied, true);
    });

    test('rejects a new order on a table that already has an open order', () {
      service.createOrder(orderId: 'O1', tableId: 1);

      expect(
        () => service.createOrder(orderId: 'O2', tableId: 1),
        throwsException,
      );
    });

    test('computes the order total from its items', () {
      service.createOrder(orderId: 'O1', tableId: 1);
      service.addItemToOrder(orderId: 'O1', menuItemId: 'M1', quantity: 2);
      service.addItemToOrder(orderId: 'O1', menuItemId: 'M2', quantity: 1);

      final total = service.calculateOrderTotal(orderId: 'O1');

      expect(total, closeTo(30.5, 0.001));
    });

    test('closing an order frees its table and returns the final total', () {
      service.createOrder(orderId: 'O1', tableId: 1);
      service.addItemToOrder(orderId: 'O1', menuItemId: 'M1', quantity: 1);

      final total = service.closeOrder(orderId: 'O1');
      final table = service.tables.firstWhere((t) => t.id == 1);

      expect(total, closeTo(12.0, 0.001));
      expect(table.isOccupied, false);
    });

    test('pays a closed order for the exact total', () {
      service.createOrder(orderId: 'O1', tableId: 1);
      service.addItemToOrder(orderId: 'O1', menuItemId: 'M1', quantity: 1);
      service.closeOrder(orderId: 'O1');

      final payment = service.payOrder(paymentId: 'P1', orderId: 'O1', method: 'card');

      expect(payment.amount, closeTo(12.0, 0.001));
      expect(service.payments.length, 1);
    });

    test('rejects paying for an order that is not yet closed', () {
      service.createOrder(orderId: 'O1', tableId: 1);

      expect(
        () => service.payOrder(paymentId: 'P1', orderId: 'O1', method: 'card'),
        throwsException,
      );
    });

    test('accepts a reservation for an available table', () {
      service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 2,
        dateTime: DateTime(2026, 1, 1, 19, 0),
      );

      expect(service.reservations.length, 1);
      expect(service.reservations.first.id, 'R1');
    });

    test('rejects a second reservation for the same table at the same time', () {
      service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 1,
        dateTime: DateTime(2026, 1, 1, 19, 0),
      );

      expect(
        () => service.makeReservation(
          reservationId: 'R2',
          customerId: 'C1',
          tableId: 1,
          dateTime: DateTime(2026, 1, 1, 19, 0),
        ),
        throwsException,
      );
    });

    test('removing a customer also removes their reservations', () {
      service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 1,
        dateTime: DateTime(2026, 1, 1, 19, 0),
      );

      service.removeCustomer(customerId: 'C1');

      expect(service.customers, isEmpty);
      expect(service.reservations, isEmpty);
    });
  });
}
