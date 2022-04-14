import 'method_channel_shared_preferences_store.dart';

abstract class CompatSharedPreferencesStorePlatform {
  static CompatSharedPreferencesStorePlatform get instance => _instance;

  static set instance(CompatSharedPreferencesStorePlatform value) {
    try {
      value._verifyProvidesDefaultImplementations();
    } on NoSuchMethodError catch (_) {
      throw AssertionError(
          'Platform interfaces must not be implemented with `implements`');
    }
    _instance = value;
  }

  static CompatSharedPreferencesStorePlatform _instance =
      MethodChannelSharedPreferencesStore();

  Future<bool> remove(String key);

  Future<bool> setValue(String valueType, String key, Object value);

  Future<bool> clear();

  Future<Map<String, Object>> getAll();

  void _verifyProvidesDefaultImplementations() {}
}
