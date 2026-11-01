import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class HardwareInfo extends StatefulWidget {
  const HardwareInfo({super.key});

  @override
  State<HardwareInfo> createState() => _HardwareInfoState();
}

class _HardwareInfoState extends State<HardwareInfo> {
  final deviceInfoPlugin = DeviceInfoPlugin();

  AndroidDeviceInfo? deviceInfo;

  String imageUrl = '';

  bool loading = true;
  bool imageLoading = false;

  @override
  void initState() {
    super.initState();
    loadDeviceInfo();
  }

  Future<void> loadDeviceInfo() async {
    try {
      final info = await deviceInfoPlugin.androidInfo;

      setState(() {
        deviceInfo = info;
      });

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint('Device info error: $e');

      setState(() {
        loading = false;
      });
    }
  }

  String normalizeModel(String input) {
    return input
        .replaceAll('5G UW', '')
        .replaceAll('5G UC', '')
        .replaceAll('Dual SIM', '')
        .replaceAll('LTE', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<Map<String, dynamic>> buildHardwareData(AndroidDeviceInfo info) {
    return [
      {'title': 'Brand', 'value': info.brand, 'icon': Icons.business},
      {
        'title': 'Manufacturer',
        'value': info.manufacturer,
        'icon': Icons.factory,
      },
      {'title': 'Model', 'value': info.model, 'icon': Icons.smartphone},
      {'title': 'Device', 'value': info.device, 'icon': Icons.devices},
      {'title': 'Product', 'value': info.product, 'icon': Icons.inventory_2},
      {'title': 'Board', 'value': info.board, 'icon': Icons.developer_board},
      {'title': 'Hardware', 'value': info.hardware, 'icon': Icons.memory},
      {
        'title': 'Bootloader',
        'value': info.bootloader,
        'icon': Icons.settings_applications,
      },
      {'title': 'Host', 'value': info.host, 'icon': Icons.dns},
      {'title': 'ID', 'value': info.id, 'icon': Icons.fingerprint},
      {
        'title': 'Fingerprint',
        'value': info.fingerprint,
        'icon': Icons.security,
      },
      {
        'title': 'Android Version',
        'value': info.version.release,
        'icon': Icons.android,
      },
      {'title': 'SDK', 'value': '${info.version.sdkInt}', 'icon': Icons.code},
      {
        'title': 'Security Patch',
        'value': info.version.securityPatch ?? 'Unknown',
        'icon': Icons.shield,
      },
      {
        'title': 'Codename',
        'value': info.version.codename,
        'icon': Icons.badge,
      },
      {
        'title': 'Supported ABIs',
        'value': info.supportedAbis.join(', '),
        'icon': Icons.developer_mode,
      },
      {
        'title': 'Is Physical Device',
        'value': '${info.isPhysicalDevice}',
        'icon': Icons.phone_android,
      },
      {'title': 'Tags', 'value': info.tags, 'icon': Icons.sell},
      {'title': 'Type', 'value': info.type, 'icon': Icons.category},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'HARDWARE INFO'),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  ...buildHardwareData(deviceInfo!).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade800),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),

                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),

                            child: Icon(
                              item['icon'],
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),

                          title: Text(
                            item['title'],
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: SelectableText(
                              item['value'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: Colors.white70,
                              size: 20,
                            ),

                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: item['value']),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item['title']} copied'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
