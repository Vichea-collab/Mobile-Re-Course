class Measurement {
  String sensorName;
  double value;
  String unit;
  String? comment;

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

class SensorConfig {
  String sensorName;
  double? min;
  double? max;

  SensorConfig(this.sensorName, {this.min, this.max});

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
    List<Measurement> result = [];
    for (Measurement m in measurements) {
      if (m.sensorName == sensorName) {
        result.add(m);
      }
    }
    return result;
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

  String checkValue(double value, SensorConfig config) {
    return config.isInRange(value) ? 'OK' : 'OUTSIDE RANGE';
  }
}

void main() {
  Telemetry t = Telemetry();

  t.addMeasurement('temperature', 24.5, '°C', 'Normal');
  t.addMeasurement('battery', 87, '%');
  t.addMeasurement('altitude', 540, 'km', 'Stable');
  t.addMeasurement('temperature', 27.2, '°C');
  t.addMeasurement('speed', 7.6, 'km/s');

  print('--- All measurements ---');
  t.displayAll();

  print('\n--- Find "temperature" ---');
  for (Measurement m in t.findBySensor('temperature')) {
    print('-> ${m.value} ${m.unit}');
  }

  print('\n--- Average temperature ---');
  print('${t.average('temperature')} °C');

  SensorConfig tempConfig = SensorConfig('temperature', min: 0, max: 50);

  print('\n--- Check temperature (0 to 50) ---');
  print('24.5 -> ${t.checkValue(24.5, tempConfig)}');
  print('27.2 -> ${t.checkValue(27.2, tempConfig)}');
  print('-5 -> ${t.checkValue(-5, tempConfig)}');

  SensorConfig batteryConfig = SensorConfig('battery', min: 20, max: 100);

  print('\n--- Check battery (20 to 100) ---');
  print('87 -> ${t.checkValue(87, batteryConfig)}');
  print('10 -> ${t.checkValue(10, batteryConfig)}');
  print('105 -> ${t.checkValue(105, batteryConfig)}');
}
