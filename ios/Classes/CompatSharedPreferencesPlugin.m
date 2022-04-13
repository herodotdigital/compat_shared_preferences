#import "CompatSharedPreferencesPlugin.h"
#if __has_include(<compat_shared_preferences/compat_shared_preferences-Swift.h>)
#import <compat_shared_preferences/compat_shared_preferences-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "compat_shared_preferences-Swift.h"
#endif

@implementation CompatSharedPreferencesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCompatSharedPreferencesPlugin registerWithRegistrar:registrar];
}
@end
