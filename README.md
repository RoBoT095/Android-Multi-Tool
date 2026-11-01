# Android_Multi_Tool

This is a playground project where I try to see what android is capable of and maybe use it to understand things better for the future like how does android read bluetooth signals and what different sensors on the device see

## Permission Usage

<!-- ## Internet

Internet is currently only used in attempt to pull an image of your device when accessing the hardware info screen. This app does not collect, store, or use any data the app has access too. -->

### Location

Location data is only requested on GPS screen to show you data like latitude, longitude, traveling speed, etc. None of this data is stored or collected by app/provider

## Brainstorming

### Sensors

- Accelerometer (graph + tilt) - [sensors_plus](https://pub.dev/packages/sensors_plus)
- Gyroscope (rotating cube)
- Barometer (pressure gauge)
- 3D Compass (magnetometer)
- GPS (speedometer + coordinates display) - [geolocator](https://pub.dev/packages/geolocator)
- Light sensor (lux meter) - [light](https://pub.dev/packages/light)

### Device

- Battery (percent + temperature + voltage + capacity) - [battery_info fork](https://github.com/EttoreCaputo/flutter_battery_info)
- CPU and RAM usage - [system_info2](https://pub.dev/packages/system_info2)
- Storage breakdown (total + used + free) - [storage_space](https://pub.dev/packages/storage_space)
- Device model + Android version - [device_info_plus](https://pub.dev/packages/device_info_plus)

### Wireless

- Bluetooth (select connected device + view traffic data) - [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus#usage)
- Wifi Scanning - [WiFiFlutter](https://flutternetwork.github.io/WiFiFlutter/)
  - BSSID: The unique MAC address of the access point
  - SSID: The network name
  - Signal strength
  - Security type
  - Channel
  - Frequency
- Mobile Data - [system_state](https://pub.dev/packages/system_state)
  - Provider
  - RSSI
  - Band channel
  - Roaming
  - SIM state
  - Service state
  - Data NW
  - Voice NW

### Audio

- Decibels (decibel meter) - [noise_meter](https://pub.dev/packages/noise_meter)

## Possible Future Additions

### Audio

- Live waveform
- Frequency analyzer (so have built-in recorder?)

### Utility Tools

- Units Converter (like fossify calculator but better) - [units_converter](https://pub.dev/packages/units_converter)
- Flashlight (with different modes) - [torch_light](https://pub.dev/packages/torch_light)

## ToDo List

- Add parameters to sensor screens
- Add settings to remember changes like using defaulting to km/h instead of mph
- Add global setting to keep screen alive all the time
