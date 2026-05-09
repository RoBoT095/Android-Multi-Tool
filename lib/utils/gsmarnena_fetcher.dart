import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class GSMArenaImageFetcher {
  static const String _baseUrl = 'https://www.gsmarena.com';

  /// Returns the image URL for a device model
  /// Example:
  /// await GSMArenaImageFetcher.fetchImage("Samsung Galaxy S24 Ultra");
  static Future<String?> fetchImage(String model) async {
    try {
      // GSMArena search endpoint
      final searchUrl =
          '$_baseUrl/results.php3?sQuickSearch=yes&sName=${Uri.encodeComponent(model)}';

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final document = parser.parse(response.body);

      // First search result
      final firstDevice = document.querySelector('.makers ul li a');

      if (firstDevice == null) {
        return null;
      }

      // Device page URL
      final deviceUrl = '$_baseUrl/${firstDevice.attributes['href']}';

      final deviceResponse = await http.get(
        Uri.parse(deviceUrl),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (deviceResponse.statusCode != 200) {
        return null;
      }

      final deviceDoc = parser.parse(deviceResponse.body);

      // Main image selector
      final imageElement = deviceDoc.querySelector('.specs-photo-main img');

      final imageUrl = imageElement?.attributes['src'];

      return imageUrl;
    } catch (e) {
      print('GSMArena fetch error: $e');
      return null;
    }
  }
}
