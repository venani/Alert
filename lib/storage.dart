import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences storage = null;
  static List<String> items = [];

  static Future<SharedPreferences> getStorage() async {
    if (storage == null) {
      storage = await SharedPreferences.getInstance();
    }
    return storage;
  }

  static List<String> getList(String key) {
    items = storage.getStringList(key);
    return items;
  }
}
