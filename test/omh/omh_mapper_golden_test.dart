import 'package:cairn/src/health/health_metric.dart';
import 'package:cairn/src/health/health_sample.dart';
import 'package:cairn/src/health/health_source.dart';
import 'package:cairn/src/omh/default_omh_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the exact emitted shape so an accidental field/unit/format change
/// fails loudly — the on-disk format is the product (DESIGN.md §13).
///
/// The local UTC offset depends on the test machine's timezone, so timestamps
/// are asserted by format + wall-clock prefix rather than an exact offset.
void main() {
  final mapper = DefaultOmhMapper();
  const source = HealthSource(
    name: 'Galaxy Fit3',
    platform: HealthPlatform.googleHealthConnect,
    recordingMethod: RecordingMethodKind.automatic,
  );
  final offsetTs = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$',
  );
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  Map<String, Object?> asMap(Object? value) => value! as Map<String, Object?>;

  test('heart-rate datapoint has the exact OMH shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.heartRate,
        value: 62,
        unit: 'count/min',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(body.keys, unorderedEquals(['heart_rate', 'effective_time_frame']));
    expect(body['heart_rate'], {'value': 62.0, 'unit': 'beats/min'});
    final ts = asMap(body['effective_time_frame'])['date_time']! as String;
    expect(ts, startsWith('2026-06-14T08:30:55'));
    expect(ts, matches(offsetTs));

    final header = asMap(dp['header']);
    expect(
      header.keys,
      unorderedEquals([
        'id',
        'creation_date_time',
        'schema_id',
        'acquisition_provenance',
      ]),
    );
    expect(header['schema_id'], {
      'namespace': 'omh',
      'name': 'heart-rate',
      'version': '1.0',
    });
    expect(header['id']! as String, matches(uuidV4));
    final prov = asMap(header['acquisition_provenance']);
    expect(prov['source_name'], 'Galaxy Fit3');
    expect(prov['modality'], 'sensed');
  });

  test('body fat percentage has the exact schema shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyFatPercentage,
        value: 18.5,
        unit: '%',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(
      body.keys,
      unorderedEquals(['body_fat_percentage', 'effective_time_frame']),
    );
    expect(body['body_fat_percentage'], {'value': 18.5, 'unit': '%'});

    final header = asMap(dp['header']);
    expect(header['schema_id'], {
      'namespace': 'omh',
      'name': 'body-fat-percentage',
      'version': '1.0',
    });
  });

  test('lean body mass has the exact schema shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.leanBodyMass,
        value: 61.2,
        unit: 'kg',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(
      body.keys,
      unorderedEquals(['lean_body_mass', 'effective_time_frame']),
    );
    expect(body['lean_body_mass'], {'value': 61.2, 'unit': 'kg'});

    final header = asMap(dp['header']);
    expect(header['schema_id'], {
      'namespace': 'cairn',
      'name': 'lean-body-mass',
      'version': '1.0',
    });
  });

  test('body mass index has the exact schema shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyMassIndex,
        value: 23.1,
        unit: 'kg/m2',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(
      body.keys,
      unorderedEquals(['body_mass_index', 'effective_time_frame']),
    );
    expect(body['body_mass_index'], {'value': 23.1, 'unit': 'kg/m2'});

    final header = asMap(dp['header']);
    expect(header['schema_id'], {
      'namespace': 'omh',
      'name': 'body-mass-index',
      'version': '1.0',
    });
  });

  test('body water mass has the exact schema shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyWaterMass,
        value: 45,
        unit: 'kg',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(
      body.keys,
      unorderedEquals(['body_water_mass', 'effective_time_frame']),
    );
    expect(body['body_water_mass'], {'value': 45.0, 'unit': 'kg'});

    final header = asMap(dp['header']);
    expect(header['schema_id'], {
      'namespace': 'cairn',
      'name': 'body-water-mass',
      'version': '1.0',
    });
  });

  test('body height has the exact schema shape', () {
    final t = DateTime(2026, 6, 14, 8, 30, 55);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.height,
        value: 180,
        unit: 'cm',
        start: t,
        end: t,
        source: source,
      ),
    );

    final body = asMap(dp['body']);
    expect(
      body.keys,
      unorderedEquals(['body_height', 'effective_time_frame']),
    );
    expect(body['body_height'], {'value': 180.0, 'unit': 'cm'});

    final header = asMap(dp['header']);
    expect(header['schema_id'], {
      'namespace': 'omh',
      'name': 'body-height',
      'version': '1.0',
    });
  });

  test('step-count uses a time_interval frame with the steps unit', () {
    final start = DateTime(2026, 6, 14);
    final end = DateTime(2026, 6, 15);
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.steps,
        value: 8421,
        unit: 'count',
        start: start,
        end: end,
        source: source,
      ),
    );
    final body = asMap(dp['body']);
    expect(body['step_count'], {'value': 8421.0, 'unit': 'steps'});
    final frame = asMap(body['effective_time_frame']);
    final interval = asMap(frame['time_interval']);
    expect(
      interval.keys,
      unorderedEquals(['start_date_time', 'end_date_time']),
    );
    expect(interval['start_date_time']! as String, startsWith('2026-06-14T'));
  });

  test('workout emits IEEE physical-activity fields with correct units', () {
    final start = DateTime(2026, 6, 14, 7);
    final end = DateTime(2026, 6, 14, 8);
    final dp = mapper.toDataPoint(
      WorkoutSample(
        start: start,
        end: end,
        source: source,
        activityName: 'running',
        totalDistanceMeters: 9000,
        totalEnergyKcal: 600,
        totalSteps: 11000,
      ),
    );
    final body = asMap(dp['body']);
    expect(body['activity_name'], 'running');
    expect(body['distance'], {'value': 9000.0, 'unit': 'm'});
    expect(body['kcal_burned'], {'value': 600.0, 'unit': 'kcal'});
    expect(body['base_movement_quantity'], {'value': 11000.0, 'unit': 'steps'});
    expect(body['duration'], {'value': 60.0, 'unit': 'min'});
  });
}
