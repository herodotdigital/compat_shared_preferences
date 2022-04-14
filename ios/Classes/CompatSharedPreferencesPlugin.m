#import "CompatSharedPreferencesPlugin.h"
#if __has_include(<compat_shared_preferences/compat_shared_preferences-Swift.h>)
#import <compat_shared_preferences/compat_shared_preferences-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "compat_shared_preferences-Swift.h"
#endif

static NSString *const CHANNEL_NAME = @"compat_shared_preferences";

@implementation CompatSharedPreferencesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [self legacyNSUserDefaultsImplementation:registrar];
    //  implementation from .swift file
    //  uncomment when you're 100% sure that the types are correctly mapped
    //  and are 100% compatible with the legacy implementation
    //  [SwiftCompatSharedPreferencesPlugin registerWithRegistrar:registrar];
}

+ (void)legacyNSUserDefaultsImplementation:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                                                binaryMessenger:registrar.messenger];
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        NSString *method = [call method];
        NSDictionary *arguments = [call arguments];
        
        if ([method isEqualToString:@"getAll"]) {
            result(getAllPrefs());
        } else if ([method isEqualToString:@"setBool"]) {
            NSString *key = arguments[@"key"];
            NSNumber *value = arguments[@"value"];
            [[NSUserDefaults standardUserDefaults] setBool:value.boolValue forKey:key];
            result(@YES);
        } else if ([method isEqualToString:@"setInt"]) {
            NSString *key = arguments[@"key"];
            NSNumber *value = arguments[@"value"];
            // int type in Dart can come to native side in a variety of forms
            // It is best to store it as is and send it back when needed.
            // Platform channel will handle the conversion.
            [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
            result(@YES);
        } else if ([method isEqualToString:@"setDouble"]) {
            NSString *key = arguments[@"key"];
            NSNumber *value = arguments[@"value"];
            [[NSUserDefaults standardUserDefaults] setDouble:value.doubleValue forKey:key];
            result(@YES);
        } else if ([method isEqualToString:@"setString"]) {
            NSString *key = arguments[@"key"];
            NSString *value = arguments[@"value"];
            [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
            result(@YES);
        } else if ([method isEqualToString:@"setStringList"]) {
            NSString *key = arguments[@"key"];
            NSArray *value = arguments[@"value"];
            [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
            result(@YES);
        } else if ([method isEqualToString:@"commit"]) {
            // synchronize is deprecated.
            // "this method is unnecessary and shouldn't be used."
            result(@YES);
        } else if ([method isEqualToString:@"remove"]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:arguments[@"key"]];
            result(@YES);
        } else if ([method isEqualToString:@"clear"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            for (NSString *key in getAllPrefs()) {
                [defaults removeObjectForKey:key];
            }
            result(@YES);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

#pragma mark - Private

static NSMutableDictionary *getAllPrefs() {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:appDomain];
    NSMutableDictionary *filteredPrefs = [NSMutableDictionary dictionary];
    if (prefs != nil) {
        for (NSString *candidateKey in prefs) {
            [filteredPrefs setObject:prefs[candidateKey] forKey:candidateKey];
        }
    }
    return filteredPrefs;
}

@end

