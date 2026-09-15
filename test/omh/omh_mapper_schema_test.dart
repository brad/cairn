import 'package:cairn/src/health/health_metric.dart';
import 'package:cairn/src/health/health_sample.dart';
import 'package:cairn/src/health/health_source.dart';
import 'package:cairn/src/health/sleep_aggregator.dart';
import 'package:cairn/src/omh/default_omh_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

import '../support/omh_schemas.dart';

void main() {
  late OmhSchemas schemas;
  late DefaultOmhMapper mapper;

  setUpAll(() {
    schemas = OmhSchemas.load();
    mapper = DefaultOmhMapper();
  });

  Map<String, Object?> bodyOf(Map<String, Object?> dataPoint) =>
      dataPoint['body']! as Map<String, Object?>;
  Map<String, Object?> headerOf(Map<String, Object?> dataPoint) =>
      dataPoint['header']! as Map<String, Object?>;

  void expectValid(JsonSchema schema, Object? instance) {
    final result = schema.validate(instance);
    expect(result.isValid, isTrue, reason: result.errors.join('\n'));
  }

  const sensed = HealthSource(
    name: 'Galaxy Fit3',
    platform: HealthPlatform.googleHealthConnect,
    recordingMethod: RecordingMethodKind.automatic,
  );
  const selfReported = HealthSource(
    name: 'Manual entry',
    platform: HealthPlatform.appleHealth,
    recordingMethod: RecordingMethodKind.manual,
  );
  final t0 = DateTime(2026, 6, 14, 8, 30, 55);
  final t1 = DateTime(2026, 6, 14, 8, 31, 55);

  test('heart rate maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.heartRate,
        value: 62,
        unit: 'count/min',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.heartRate, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('step count maps to a schema-valid interval body', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.steps,
        value: 1234,
        unit: 'count',
        start: t0,
        end: t1,
        source: sensed,
      ),
    );
    expectValid(schemas.stepCount, bodyOf(dp));
  });

  test('body weight maps to a schema-valid body; manual => self-reported', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.weight,
        value: 72.5,
        unit: 'kg',
        start: t0,
        end: t0,
        source: selfReported,
      ),
    );
    expectValid(schemas.bodyWeight, bodyOf(dp));
    final provenance =
        headerOf(dp)['acquisition_provenance']! as Map<String, Object?>;
    expect(provenance['modality'], 'self-reported');
  });

  test('body fat percentage maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyFatPercentage,
        value: 18.5,
        unit: '%',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.bodyFatPercentage, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('lean body mass maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.leanBodyMass,
        value: 58.2,
        unit: 'kg',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.leanBodyMass, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('body mass index maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyMassIndex,
        value: 22.4,
        unit: 'kg/m2',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.bodyMassIndex, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('body water mass maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.bodyWaterMass,
        value: 42.1,
        unit: 'kg',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.bodyWaterMass, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('body height maps to a schema-valid body + header', () {
    final dp = mapper.toDataPoint(
      ScalarSample(
        metric: HealthMetric.height,
        value: 178,
        unit: 'cm',
        start: t0,
        end: t0,
        source: sensed,
      ),
    );
    expectValid(schemas.bodyHeight, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });

  test('workout maps to a schema-valid IEEE physical-activity body', () {
    final dp = mapper.toDataPoint(
      WorkoutSample(
        start: t0,
        end: t1,
        source: sensed,
        activityName: 'running',
        totalDistanceMeters: 5200,
        totalEnergyKcal: 410,
        totalSteps: 8000,
      ),
    );
    expectValid(schemas.physicalActivity, bodyOf(dp));
  });

  test('sleep segment maps to a schema-valid cairn:sleep-stage body', () {
    final dp = mapper.toDataPoint(
      SleepSegmentSample(
        start: t0,
        end: t1,
        source: sensed,
        stage: SleepStage.rem,
      ),
    );
    expectValid(schemas.sleepStage, bodyOf(dp));
  });

  test('aggregated night maps to a schema-valid sleep-episode body', () {
    final night = DateTime(2026, 6, 13, 23);
    final segments = [
      SleepSegmentSample(
        start: night,
        end: night.add(const Duration(minutes: 60)),
        source: sensed,
        stage: SleepStage.light,
      ),
      SleepSegmentSample(
        start: night.add(const Duration(minutes: 60)),
        end: night.add(const Duration(minutes: 150)),
        source: sensed,
        stage: SleepStage.deep,
      ),
      SleepSegmentSample(
        start: night.add(const Duration(minutes: 150)),
        end: night.add(const Duration(minutes: 160)),
        source: sensed,
        stage: SleepStage.awake,
      ),
      SleepSegmentSample(
        start: night.add(const Duration(minutes: 160)),
        end: night.add(const Duration(minutes: 220)),
        source: sensed,
        stage: SleepStage.rem,
      ),
    ];
    final episodes = const SleepEpisodeAggregator().aggregate(segments);
    expect(episodes, hasLength(1));
    final dp = mapper.sleepEpisodeToDataPoint(episodes.single);
    expectValid(schemas.sleepEpisode, bodyOf(dp));
    expectValid(schemas.header, headerOf(dp));
  });
}
