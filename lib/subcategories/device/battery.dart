import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';
import 'package:android_multi_tool/components/data_grid_tile.dart';

const _defaultColor = Color(0xFF2196F3);
const _veryLowBatColor = Color(0xFFF44336); // < 25%
const _lowBatColor = Color(0xFFFF9800); // < 50%
const _midChargeBatColor = Color(0xFFFFC107); // < 75%
const _chargedBatColor = Color(0xFF4CAF50); // > 75%

Color _batteryColor(int? level) {
  if (level == null) return _defaultColor;
  if (level <= 20) return _veryLowBatColor;
  if (level <= 50) return _lowBatColor;
  if (level < 75) return _midChargeBatColor;
  return _chargedBatColor;
}

class BatteryInfo extends StatefulWidget {
  const BatteryInfo({super.key});

  @override
  State<BatteryInfo> createState() => _BatteryInfoState();
}

class _BatteryInfoState extends State<BatteryInfo> {
  StreamSubscription<AndroidBatteryInfo?>? _subscription;
  AndroidBatteryInfo? _info;

  @override
  void initState() {
    super.initState();
    _subscription = BatteryInfoPlugin().androidBatteryInfoStream.listen((info) {
      setState(() => _info = info);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'BATTERY'),
      body: SafeArea(
        child: _info == null
            ? Center(child: CircularProgressIndicator())
            : _BatteryBody(info: _info!),
      ),
    );
  }
}

class _BatteryBody extends StatelessWidget {
  final AndroidBatteryInfo info;
  const _BatteryBody({required this.info});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final level = info.batteryLevel;
    final gaugeColor = _batteryColor(level);
    final isCharging = info.chargingStatus == ChargingStatus.Charging;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          _BatteryGauge(
            level: level,
            isCharging: isCharging,
            color: gaugeColor,
          ),

          const SizedBox(height: 28),
          _InfoGrid(info: info, cs: cs),
        ],
      ),
    );
  }
}

class _BatteryGauge extends StatelessWidget {
  final int? level;
  final bool isCharging;
  final Color color;

  const _BatteryGauge({
    required this.level,
    required this.isCharging,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pct = (level ?? 0) / 100.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: pct,
            strokeWidth: 16,
            strokeCap: StrokeCap.round,
            backgroundColor: cs.surfaceContainerHighest,
            color: color,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCharging ? Icons.bolt : Icons.battery_std,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              level != null ? '$level%' : '—',
              style: tt.displaySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isCharging ? 'Charging' : 'Discharging',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final AndroidBatteryInfo info;
  final ColorScheme cs;

  const _InfoGrid({required this.info, required this.cs});

  String _formatChargeTime(int? milliseconds) {
    if (milliseconds == null || milliseconds < 0) return 'N/A';
    final minutes = (milliseconds / 1000 / 60).truncate();
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  String _formatCurrent(int? microAmp) {
    if (microAmp == null) return 'N/A';
    final mA = microAmp / 1000;
    return '${mA.toStringAsFixed(1)} mA';
  }

  String _formatTemperature(int? tenths) {
    if (tenths == null) return 'N/A';
    return '${(tenths / 10).toStringAsFixed(1)} °C';
  }

  String _formatVoltage(int? milliVolts) {
    if (milliVolts == null) return 'N/A';
    return '${(milliVolts / 1000).toStringAsFixed(3)} V';
  }

  String _formatEnergy(int? nanoWattHours) {
    if (nanoWattHours == null) return 'N/A';
    final milliWattHours = nanoWattHours / 1e6;
    return '${milliWattHours.toStringAsFixed(1)} mWh';
  }

  String _formatCapacity(int? milliAmpHours) {
    if (milliAmpHours == null) return 'N/A';
    return '$milliAmpHours mAh';
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      DataGridTile(
        icon: Icons.storage,
        label: 'Capacity',
        value: _formatCapacity(info.batteryCapacity),
        iconColor: cs.primary,
      ),
      DataGridTile(
        icon: Icons.memory,
        label: 'Technology',
        value: info.technology ?? 'N/A',
        iconColor: cs.secondary,
      ),

      DataGridTile(
        icon: Icons.power,
        label: 'Plugged',
        value: info.pluggedStatus ?? 'N/A',
        iconColor: cs.secondary,
      ),
      DataGridTile(
        icon: Icons.timer,
        label: 'Charge Time',
        value: _formatChargeTime(info.chargeTimeRemaining),
        iconColor: cs.primary,
      ),
      DataGridTile(
        icon: Icons.bolt,
        label: 'Current Now',
        value: _formatCurrent(info.currentNow),
        iconColor: cs.tertiary,
      ),
      DataGridTile(
        icon: Icons.show_chart,
        label: 'Current Avg',
        value: _formatCurrent(info.currentAverage),
        iconColor: cs.secondary,
      ),
      DataGridTile(
        icon: Icons.favorite,
        label: 'Health',
        value: info.health ?? 'N/A',
        iconColor: _healthColor(info.health),
      ),
      DataGridTile(
        icon: Icons.thermostat,
        label: 'Temperature',
        value: _formatTemperature(info.temperature),
        iconColor: cs.secondary,
      ),
      DataGridTile(
        icon: Icons.electrical_services,
        label: 'Voltage',
        value: _formatVoltage(info.voltage),
        iconColor: cs.tertiary,
      ),
      DataGridTile(
        icon: Icons.energy_savings_leaf,
        label: 'Remaining Energy',
        value: _formatEnergy(info.remainingEnergy),
        iconColor: cs.primary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) => tiles[i],
    );
  }

  Color _healthColor(String? health) {
    switch (health?.toLowerCase()) {
      case 'health_good':
        return _chargedBatColor;
      case 'over_heat' || 'dead' || 'over_voltage' || 'failure':
        return _veryLowBatColor;
      default:
        return _defaultColor;
    }
  }
}
