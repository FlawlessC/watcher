import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static const String currentVersion = "1.0.0";

  static const String url =
      "https://raw.githubusercontent.com/FlawlessC/watcher/main/version.json";

  static Future<void> checkForUpdate({
    required Function(String apkUrl, String changelog) onUpdate,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);

      final latestVersion = data["version"];
      final apkUrl = data["apk_url"];
      final changelog = data["changelog"];

      if (_isNewVersion(latestVersion, currentVersion)) {
        onUpdate(apkUrl, changelog);
      }
    } catch (e) {
      // тихо игнорируем ошибки сети
    }
  }

  static bool _isNewVersion(String latest, String current) {
    return latest != current;
  }
}