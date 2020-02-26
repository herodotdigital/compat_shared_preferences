import 'dart:async';
import 'src/compat_shared_preferences_store_platform.dart';

class CompatSharedPreferences {
  CompatSharedPreferences._(this._preferenceCache);

  static Completer<CompatSharedPreferences> _completer;

  static CompatSharedPreferencesStorePlatform get _store =>
      CompatSharedPreferencesStorePlatform.instance;

  static Future<CompatSharedPreferences> getInstance() async {
    if (_completer == null) {
      _completer = Completer<CompatSharedPreferences>();
      try {
        final Map<String, Object> preferencesMap =
            await _getCompatSharedPreferencesMap();
        _completer.complete(CompatSharedPreferences._(preferencesMap));
      } on Exception catch (e) {
        _completer.completeError(e);
        final Future<CompatSharedPreferences> sharedPrefsFuture =
            _completer.future;
        _completer = null;
        return sharedPrefsFuture;
      }
    }
    return _completer.future;
  }

  final Map<String, Object> _preferenceCache;

  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  dynamic get(String key) => _preferenceCache[key];

  bool getBool(String key) => _preferenceCache[key];

  int getInt(String key) => _preferenceCache[key];

  double getDouble(String key) => _preferenceCache[key];

  String getString(String key) => _preferenceCache[key];

  bool containsKey(String key) => _preferenceCache.containsKey(key);

  List<String> getStringList(String key) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }

    return list?.toList();
  }

  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  Future<bool> setDouble(String key, double value) =>
      _setValue('Double', key, value);

  Future<bool> setString(String key, String value) =>
      _setValue('String', key, value);

  Future<bool> setStringList(String key, List<String> value) =>
      _setValue('StringList', key, value);

  Future<bool> remove(String key) => _setValue(null, key, null);

  Future<bool> _setValue(String valueType, String key, Object value) {
    final String prefixedKey = '$key';
    if (value == null) {
      _preferenceCache.remove(key);
      return _store.remove(prefixedKey);
    } else {
      if (value is List<String>) {
        _preferenceCache[key] = value.toList();
      } else {
        _preferenceCache[key] = value;
      }
      return _store.setValue(valueType, prefixedKey, value);
    }
  }

  @deprecated
  Future<bool> commit() async => true;

  Future<bool> clear() {
    _preferenceCache.clear();
    return _store.clear();
  }

  Future<void> reload() async {
    final Map<String, Object> preferences =
        await CompatSharedPreferences._getCompatSharedPreferencesMap();
    _preferenceCache.clear();
    _preferenceCache.addAll(preferences);
  }

  static Future<Map<String, Object>> _getCompatSharedPreferencesMap() async {
    final Map<String, Object> fromSystem = await _store.getAll();
    assert(fromSystem != null);

    final Map<String, Object> preferencesMap = <String, Object>{};
    for (String key in fromSystem.keys) {
      preferencesMap[key] = fromSystem[key];
    }
    return preferencesMap;
  }
}
