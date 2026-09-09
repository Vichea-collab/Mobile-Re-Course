import '../model/customer.dart';
import '../model/menu_item.dart';
import '../model/order.dart';
import '../model/payment.dart';
import '../model/reservation.dart';
import '../model/table.dart';

class RestaurantService {
  final List<MenuItem> menu = [];
  final List<Table> tables = [];
  final List<Customer> customers = [];
  final List<Order> orders = [];
  final List<Reservation> reservations = [];
  final List<Payment> payments = [];

  void addMenuItem({required MenuItem item}) {
    menu.add(item);
  }

  void addTable({required Table table}) {
    tables.add(table);
  }

  void registerCustomer({required Customer customer}) {
    customers.add(customer);
  }

  void createOrder({required String orderId, required int tableId}) {
    Table? table = _findTableOrNull(tableId);
    if (table == null) {
      throw Exception('Table $tableId not found');
    }

    bool hasOpenOrder = orders.any(
      (order) => order.table.id == tableId && order.status == OrderStatus.open,
    );
    if (hasOpenOrder) {
      throw Exception('Table $tableId already has an open order');
    }

    table.isOccupied = true;
    orders.add(Order(id: orderId, table: table));
  }

  void addItemToOrder({
    required String orderId,
    required String menuItemId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero');
    }

    Order? order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    MenuItem? item = _findMenuItemOrNull(menuItemId);
    if (item == null) {
      throw Exception('Menu item $menuItemId not found');
    }

    for (int i = 0; i < quantity; i++) {
      order.addItem(item);
    }
  }

  double closeOrder({required String orderId}) {
    Order? order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (order.status == OrderStatus.closed) {
      throw Exception('Order $orderId is already closed');
    }

    order.status = OrderStatus.closed;
    order.table.isOccupied = false;
    return order.total;
  }

  Payment payOrder({
    required String paymentId,
    required String orderId,
    required String method,
  }) {
    Order? order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (order.status != OrderStatus.closed) {
      throw Exception('Order $orderId must be closed before it can be paid');
    }

    bool alreadyPaid = payments.any((p) => p.orderId == orderId);
    if (alreadyPaid) {
      throw Exception('Order $orderId has already been paid');
    }

    Payment payment = Payment(
      id: paymentId,
      orderId: orderId,
      amount: order.total,
      method: method,
    );
    payments.add(payment);
    return payment;
  }

  double calculateOrderTotal({required String orderId}) {
    Order? order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }
    return order.total;
  }

  void makeReservation({
    required String reservationId,
    required String customerId,
    required int tableId,
    required DateTime dateTime,
  }) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }

    Table? table = _findTableOrNull(tableId);
    if (table == null) {
      throw Exception('Table $tableId not found');
    }

    bool alreadyReserved = reservations.any(
      (reservation) =>
          reservation.table.id == tableId && reservation.dateTime == dateTime,
    );
    if (alreadyReserved) {
      throw Exception('Table $tableId is already reserved at $dateTime');
    }

    reservations.add(Reservation(
      id: reservationId,
      customer: customer,
      table: table,
      dateTime: dateTime,
    ));
  }

  void cancelReservation({required String reservationId}) {
    Reservation? reservation = _findReservationOrNull(reservationId);
    if (reservation == null) {
      throw Exception('Reservation $reservationId not found');
    }
    reservations.removeWhere((r) => r.id == reservationId);
  }

  void removeCustomer({required String customerId}) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }

    customers.removeWhere((c) => c.id == customerId);
    reservations.removeWhere((r) => r.customer.id == customerId);
  }

  Table? _findTableOrNull(int tableId) {
    for (Table t in tables) {
      if (t.id == tableId) {
        return t;
      }
    }
    return null;
  }

  MenuItem? _findMenuItemOrNull(String menuItemId) {
    for (MenuItem m in menu) {
      if (m.id == menuItemId) {
        return m;
      }
    }
    return null;
  }

  Order? _findOrderOrNull(String orderId) {
    for (Order o in orders) {
      if (o.id == orderId) {
        return o;
      }
    }
    return null;
  }

  Customer? _findCustomerOrNull(String customerId) {
    for (Customer c in customers) {
      if (c.id == customerId) {
        return c;
      }
    }
    return null;
  }

  Reservation? _findReservationOrNull(String reservationId) {
    for (Reservation r in reservations) {
      if (r.id == reservationId) {
        return r;
      }
    }
    return null;
  }
}
