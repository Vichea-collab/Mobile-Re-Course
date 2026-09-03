class Measurement {
  final String sensorName;
  final double value;
  final String unit;
  final String? comment;

  Measurement(this.sensorName, this.value, this.unit, [this.comment]);

  @override
  String toString() {
    if (comment != null) {
      return '$sensorName -> $value $unit -> "$comment"';
    } else {
      return '$sensorName -> $value $unit';
    }
  }
}

class Sensor {
  final String sensorName;
  final double? min;
  final double? max;

  Sensor(this.sensorName, {this.min, this.max});

  bool isInRange(double value) {
    if (min != null && value < min!) {
      return false;
    }
    if (max != null && value > max!) {
      return false;
    }
    return true;
  }
}

class Telemetry {
  List<Measurement> measurements = [];

  void addMeasurement(
    String sensorName,
    double value,
    String unit, [
    String? comment,
  ]) {
    measurements.add(Measurement(sensorName, value, unit, comment));
  }

  void displayAll() {
    for (Measurement m in measurements) {
      print(m);
    }
  }

  List<Measurement> findBySensor(String sensorName) {
    return measurements.where((m) => m.sensorName == sensorName).toList();
  }

  void printBySensor(String sensorName) {
    for (Measurement m in findBySensor(sensorName)) {
      print('-> ${m.value} ${m.unit}');
    }
  }

  double average(String sensorName) {
    List<Measurement> found = findBySensor(sensorName);
    if (found.isEmpty) {
      return 0;
    }

    double total = 0;
    for (Measurement m in found) {
      total += m.value;
    }

    return total / found.length;
  }

  String checkValue(double value, Sensor config) {
    if (config.isInRange(value)) {
      return 'OK';
    } else {
      return 'OUTSIDE RANGE';
    }
  }
}

void main() {
  Telemetry t = Telemetry();

  t.addMeasurement('temperature', 24.5, '°C', 'Normal');
  t.addMeasurement('battery', 87, '%');
  t.addMeasurement('altitude', 540, 'km', 'Stable');
  t.addMeasurement('temperature', 27.2, '°C');
  t.addMeasurement('speed', 7.6, 'km/s');

  print(' All measurements ');
  t.displayAll();

  print('\nFind "temperature"');
  t.printBySensor('temperature');

  print('\n Average temperature ');
  print('${t.average('temperature')} °C');

  Sensor tempConfig = Sensor('temperature', min: 0, max: 50);

  print('\n Check temperature (0 to 50) ');
  print('24.5 -> ${t.checkValue(24.5, tempConfig)}');
  print('27.2 -> ${t.checkValue(27.2, tempConfig)}');
  print('-5 -> ${t.checkValue(-5, tempConfig)}');

  Sensor batteryConfig = Sensor('battery', min: 20, max: 100);

  print('\n Check battery (20 to 100) ');
  print('87 -> ${t.checkValue(87, batteryConfig)}');
  print('10 -> ${t.checkValue(10, batteryConfig)}');
  print('105 -> ${t.checkValue(105, batteryConfig)}');
}
