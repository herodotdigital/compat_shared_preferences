import 'package:flutter/services.dart';
import 'compat_shared_preferences_store_platform.dart';

const MethodChannel _channel = const MethodChannel('compat_shared_preferences');

class MethodChannelSharedPreferencesStore
    extends CompatSharedPreferencesStorePlatform {
  @override
  Future<bool> remove(String key) {
    return _invokeBoolMethod('remove', <String, dynamic>{
      'key': key,
    });
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    return _invokeBoolMethod('set$valueType', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  Future<bool> _invokeBoolMethod(String method, Map<String, dynamic> params) {
    return _channel
        .invokeMethod<bool>(method, params)
        .then<bool>((dynamic result) => result);
  }

  @override
  Future<bool> clear() {
    return _channel.invokeMethod<bool>('clear');
  }

  @override
  Future<Map<String, Object>> getAll() {
    return _channel.invokeMapMethod<String, Object>('getAll');
  }
}
