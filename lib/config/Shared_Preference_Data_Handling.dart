import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceData {
  static final SharedPreferenceData _instance = SharedPreferenceData._internal();
  late SharedPreferences _prefs;

  factory SharedPreferenceData() {
    return _instance;
  }

  SharedPreferenceData._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Existing methods ---
  Future<String?> getToken() async {
    return _prefs.getString('token') ?? 'token';
  }

  Future<void> storeToken(token) async {
    await _prefs.setString('token', token);
    return;
  }

  Future<void> setUserID(userID) async {
    await _prefs.setString('user_id', userID);
    return;
  }

  Future<String> getUserID() async {
    return _prefs.getString('user_id') ?? 'user_id';
  }

  // --- New methods for session handling ---
  Future<void> setCurrentSessionID(String sessionId) async {
    await _prefs.setString('current_session_id', sessionId);
  }

  Future<String?> getCurrentSessionID() async {
    return _prefs.getString('current_session_id');
  }

  Future<void> setCurrentChunkIndex(int index) async {
    await _prefs.setInt('current_chunk_index', index);
  }

  Future<int?> getCurrentChunkIndex() async {
    return _prefs.getInt('current_chunk_index');
  }
}
