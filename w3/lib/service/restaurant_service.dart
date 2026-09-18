import '../model/customer.dart';
import '../model/reservation.dart';
import '../model/restaurant.dart';
import '../model/table.dart';
import '../model/time_slot.dart';

class RestaurantService {
  final Restaurant restaurant;
  final List<Table> tables = [];
  final List<Customer> customers = [];
  final List<Reservation> reservations = [];

  final DateTime Function() _now;

  RestaurantService({
    required String restaurantName,
    required int openingHour,
    required int closingHour,
    int defaultDurationMinutes = 90,
    int maxLateMinutes = 20,
    DateTime Function()? now,
  })  : restaurant = Restaurant(
          name: restaurantName,
          openingHour: openingHour,
          closingHour: closingHour,
          defaultDurationMinutes: defaultDurationMinutes,
          maxLateMinutes: maxLateMinutes,
        ),
        _now = now ?? DateTime.now;

  void addTable({
    required int tableId,
    required int capacity,
    TableLocation location = TableLocation.indoor,
  }) {
    Table? table = _findTableOrNull(tableId);
    if (table != null) {
      throw Exception('Table $tableId already exists');
    }

    if (capacity <= 0) {
      throw Exception('Table capacity must be greater than zero');
    }

    tables.add(Table(id: tableId, capacity: capacity, location: location));
  }

  void addCustomer({
    required String customerId,
    required String name,
    required String phone,
  }) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer != null) {
      throw Exception('Customer $customerId already exists');
    }

    customers.add(Customer(id: customerId, name: name, phone: phone));
  }

  void makeReservation({
    required String reservationId,
    required String customerId,
    required int tableId,
    required DateTime start,
    required int partySize,
    int? durationMinutes,
    String? specialRequest,
  }) {
    releaseExpiredReservations();

    Reservation? existing = _findReservationOrNull(reservationId);
    if (existing != null) {
      throw Exception('Reservation $reservationId already exists');
    }

    Customer? customer = _findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }

    Table? table = _findTableOrNull(tableId);
    if (table == null) {
      throw Exception('Table $tableId not found');
    }

    if (table.status == TableStatus.outOfService) {
      throw Exception('Table $tableId is out of service');
    }

    if (partySize <= 0) {
      throw Exception('Party size must be greater than zero');
    }
    if (partySize > table.capacity) {
      throw Exception(
        'Table $tableId (capacity ${table.capacity}) cannot seat $partySize',
      );
    }

    TimeSlot slot = _slotFor(start, durationMinutes);
    if (!_isWithinOpeningHours(slot)) {
      throw Exception(
        'Reservation ${slot.start} - ${slot.end} is outside opening hours '
        '(${restaurant.openingHour}:00 - ${restaurant.closingHour}:00)',
      );
    }

    if (!_isTableFree(tableId, slot)) {
      throw Exception(
        'Table $tableId is already reserved between ${slot.start} and ${slot.end}',
      );
    }

    reservations.add(Reservation(
      id: reservationId,
      customerId: customerId,
      tableId: tableId,
      slot: slot,
      partySize: partySize,
      specialRequest: specialRequest,
      createdAt: _now(),
      holdUntil: start.add(Duration(minutes: restaurant.maxLateMinutes)),
    ));
  }

  void seatReservation({required String reservationId}) {
    releaseExpiredReservations();

    Reservation reservation = _findReservation(reservationId);

    if (reservation.status == ReservationStatus.noShow) {
      throw Exception(
        'Reservation $reservationId expired at ${reservation.holdUntil}; '
        'make a new reservation if the table is still free',
      );
    }

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.seated;
    _findTable(reservation.tableId).status = TableStatus.occupied;
  }

  void completeReservation({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.seated) {
      throw Exception('Reservation $reservationId has not been seated');
    }

    reservation.status = ReservationStatus.completed;
    _findTable(reservation.tableId).status = TableStatus.available;
  }

  void cancelReservation({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.cancelled;
  }

  void markNoShow({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.noShow;
  }

  int releaseExpiredReservations() {
    DateTime now = _now();
    int released = 0;
    for (Reservation r in reservations) {
      bool late = r.status == ReservationStatus.pending && now.isAfter(r.holdUntil);
      if (late) {
        r.status = ReservationStatus.noShow;
        released++;
      }
    }
    return released;
  }

  List<Table> findAvailableTables({
    required DateTime start,
    required int partySize,
    int? durationMinutes,
  }) {
    releaseExpiredReservations();

    TimeSlot slot = _slotFor(start, durationMinutes);
    List<Table> result = [];
    for (Table t in tables) {
      bool inService = t.status != TableStatus.outOfService;
      bool fits = partySize > 0 && partySize <= t.capacity;
      if (inService && fits && _isTableFree(t.id, slot)) {
        result.add(t);
      }
    }
    return result;
  }

  List<Reservation> getReservationsForDate(DateTime date) {
    List<Reservation> result = reservations
        .where((r) =>
            r.slot.start.year == date.year &&
            r.slot.start.month == date.month &&
            r.slot.start.day == date.day)
        .toList();
    result.sort((a, b) => a.slot.start.compareTo(b.slot.start));
    return result;
  }

  List<Reservation> getReservationsForCustomer({required String customerId}) {
    return reservations.where((r) => r.customerId == customerId).toList();
  }

  void removeCustomer({required String customerId}) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }

    customers.removeWhere((c) => c.id == customerId);

    reservations.removeWhere((r) => r.customerId == customerId);
  }

  TimeSlot _slotFor(DateTime start, int? durationMinutes) {
    if (durationMinutes != null && durationMinutes <= 0) {
      throw Exception('Duration must be greater than zero');
    }
    int minutes = durationMinutes ?? restaurant.defaultDurationMinutes;
    return TimeSlot(start: start, end: start.add(Duration(minutes: minutes)));
  }

  bool _isWithinOpeningHours(TimeSlot slot) {
    DateTime day = DateTime(slot.start.year, slot.start.month, slot.start.day);
    DateTime opens = day.add(Duration(hours: restaurant.openingHour));
    DateTime closes = day.add(Duration(hours: restaurant.closingHour));
    return !slot.start.isBefore(opens) && !slot.end.isAfter(closes);
  }

  bool _overlaps(TimeSlot a, TimeSlot b) {
    return a.start.isBefore(b.end) && b.start.isBefore(a.end);
  }

  bool _isTableFree(int tableId, TimeSlot slot) {
    for (Reservation r in reservations) {
      bool holdsTable = r.status == ReservationStatus.pending ||
          r.status == ReservationStatus.seated;
      bool overlaps = _overlaps(r.slot, slot);
      if (r.tableId == tableId && holdsTable && overlaps) {
        return false;
      }
    }
    return true;
  }

  Table _findTable(int tableId) {
    Table? table = _findTableOrNull(tableId);
    if (table == null) {
      throw Exception('Table $tableId not found');
    }
    return table;
  }

  Reservation _findReservation(String reservationId) {
    Reservation? reservation = _findReservationOrNull(reservationId);
    if (reservation == null) {
      throw Exception('Reservation $reservationId not found');
    }
    return reservation;
  }

  Table? _findTableOrNull(int tableId) {
    for (Table t in tables) {
      if (t.id == tableId) {
        return t;
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
