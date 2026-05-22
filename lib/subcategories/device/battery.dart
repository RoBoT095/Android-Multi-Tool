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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _subscription = BatteryInfoPlugin().androidBatteryInfoStream.listen((info) {
      setState(() => _info = info);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final info = await BatteryInfoPlugin().androidBatteryInfo;
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
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
          _InfoGrid(info: info, isCharging: isCharging),
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
  final bool isCharging;

  const _InfoGrid({required this.info, required this.isCharging});

  String _formatChargeTime(int? milliseconds) {
    if (milliseconds == null || milliseconds < 0) return 'N/A';
    final minutes = (milliseconds / 1000 / 60).truncate();
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  String _formatTemperature(int? temp) {
    if (temp == null) return 'N/A';
    return '${(temp).toStringAsFixed(1)} °C';
  }

  String _formatCurrent(int? value, bool isCharging) {
    if (value == null) return 'N/A';
    if (value == -2147483648) return 'N/A';

    double milliAmps = value.abs() > 30000 ? value / 1000.0 : value.toDouble();

    // positive = charging, negative = discharging
    final normalized = isCharging ? milliAmps.abs() : -milliAmps.abs();
    final amps = normalized / 1000.0;

    return '${amps.toStringAsFixed(3)} A';
  }

  String _formatPower(int? milliVolts, int? currentValue) {
    if (milliVolts == null ||
        currentValue == null ||
        currentValue == -2147483648) {
      return 'N/A';
    }

    double milliAmps;
    if (currentValue.abs() > 30000) {
      milliAmps = currentValue / 1000.0; // convert microAmp to milliAmp
    } else {
      milliAmps = currentValue.toDouble();
    }

    final volts = milliVolts / 1000.0;
    final watts = (volts * milliAmps) / 1000.0; // milliWatts to Watts
    return '${watts.toStringAsFixed(2)} W';
  }

  String _formatVoltage(int? milliVolts) {
    if (milliVolts == null) return 'N/A';
    return '${(milliVolts / 1000).toStringAsFixed(3)} V';
  }

  String _formatEnergy(int? nanoWattHours) {
    if (nanoWattHours == null || nanoWattHours == -2147483648) return 'N/A';
    final milliWattHours = nanoWattHours / 1e6;
    return '${milliWattHours.toStringAsFixed(1)} mWh';
  }

  String _formatCapacity(int? microAmpHours) {
    if (microAmpHours == null || microAmpHours == -2147483648) return 'N/A';
    final mAh = microAmpHours / 1000;
    return '${mAh.toStringAsFixed(0)} mAh';
  }

  String _getHealthString(String? health) {
    if (health == null) {
      return 'N/A';
    }
    if (health.toLowerCase().contains('fail')) {
      return 'Battery Failure';
    }
    switch (health.toLowerCase()) {
      case 'health_good':
        return 'Good';
      case 'over_heat':
        return 'Overheating';
      case 'over_voltage':
        return 'Over voltage';
      case 'dead':
        return 'Dead';
      default:
        return 'Unknown';
    }
  }

  Color _healthColor(String? health) {
    switch (health?.toLowerCase()) {
      case 'health_good':
        return _chargedBatColor;
      case 'over_heat' || 'dead' || 'over_voltage':
        return _veryLowBatColor;
      default:
        return _defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tiles = [
      DataGridTile(
        icon: Icons.storage,
        label: 'Current Capacity',
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
        label: 'Current',
        value: _formatCurrent(info.currentNow, isCharging),
        iconColor: cs.tertiary,
      ),
      DataGridTile(
        icon: Icons.power,
        label: 'Power',
        value: _formatPower(info.voltage, info.currentNow),
        iconColor: cs.tertiary,
      ),
      DataGridTile(
        icon: Icons.favorite,
        label: 'Health',
        value: _getHealthString(info.health),
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
}
