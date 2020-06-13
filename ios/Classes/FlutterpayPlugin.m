#import "FlutterpayPlugin.h"
#if __has_include(<flutterpay/flutterpay-Swift.h>)
#import <flutterpay/flutterpay-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterpay-Swift.h"
#endif

@implementation FlutterpayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterpayPlugin registerWithRegistrar:registrar];
}
@end
