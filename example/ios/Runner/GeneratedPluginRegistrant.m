//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<compat_shared_preferences/CompatSharedPreferencesPlugin.h>)
#import <compat_shared_preferences/CompatSharedPreferencesPlugin.h>
#else
@import compat_shared_preferences;
#endif

#if __has_include(<e2e/E2EPlugin.h>)
#import <e2e/E2EPlugin.h>
#else
@import e2e;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [CompatSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"CompatSharedPreferencesPlugin"]];
  [E2EPlugin registerWithRegistrar:[registry registrarForPlugin:@"E2EPlugin"]];
}

@end
