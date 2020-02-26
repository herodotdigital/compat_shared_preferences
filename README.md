# compat_shared_preferences

This project based on shared_preferences (https://pub.dev/packages/shared_preferences)
and have the same API.
But original project forks with custom keys adding `flutter.` prefix.
This package is useful if you not creating new application but rewriting
existing Android/iOS application with SharedPreferences/NSUserDefaults
to Flutter and want to use the same SharedPreferences store.