import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/data/raw/greeting_raw.dart';
import 'package:wedding/data/remote/api.dart';

class GreetingRepository {
  final SharedPreferences _prefs;

  GreetingRepository(this._prefs);

  Future<List<GreetingRaw>> getAll() async {
    final response = await Api.getAllGreeting();
    final data = GreetingRaw.fromJsonList(response.data);
    return data;
  }
}
