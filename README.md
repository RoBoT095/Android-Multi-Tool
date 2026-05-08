# android_multi_tool

This is a playground project where I try to see what android is capable of and maybe use it to understand things better for the future like how does android read bluetooth signals and what different sensors on the device see

## Brainstorming

### Sensors

- Accelerometer (graph + tilt) [sensors_plus](https://pub.dev/packages/sensors_plus)
- Gyroscope (rotating cube)
- Barometer (pressure gauge)
- 3D Compass (magnetometer)
- Light sensor (lux meter) [light](https://pub.dev/packages/light)
- GPS (speedometer + coordinates display) [geolocator](https://pub.dev/packages/geolocator)

### Device

- Battery (percent + temperature + voltage + capacity) [system_state](https://pub.dev/packages/system_state)
- CPU and RAM usage [system_info2](https://pub.dev/packages/system_info2)
- Storage breakdown (total + used + free) [storage_space](https://pub.dev/packages/storage_space)
- Device model + Android version [device_info_plus](https://pub.dev/packages/device_info_plus)

### Wireless

- Bluetooth (select connected device + view traffic data) [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus#usage)
- Wifi Scanning [WiFiFlutter](https://flutternetwork.github.io/WiFiFlutter/)
  - BSSID: The unique MAC address of the access point
  - SSID: The network name
  - Signal strength
  - Security type
  - Channel
  - Frequency
- Mobile Data [system_state](https://pub.dev/packages/system_state)
  - Provider
  - RSSI
  - Band channel
  - Roaming
  - SIM state
  - Service state
  - Data NW
  - Voice NW

## Possible Future Additions

### Audio

- Microphone Level (dB meter)
- Live waveform
- Frequency analyzer (so have built-in recorder?)

### Utility Tools

- Units Converter (like fossify calculator but better) [units_converter](https://pub.dev/packages/units_converter)
- Flashlight (with different modes) [torch_light](https://pub.dev/packages/torch_light)

## ToDo List

- Add parameters to sensor screens
- Add settings to remember changes like using defaulting to km/h instead of mph
- Add global setting to keep screen alive all the time
