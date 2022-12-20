#import "TnkFlutterPubPlugin.h"
#if __has_include(<tnk_flutter_pub/tnk_flutter_pub-Swift.h>)
#import <tnk_flutter_pub/tnk_flutter_pub-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tnk_flutter_pub-Swift.h"
#endif

@implementation TnkFlutterPubPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTnkFlutterPubPlugin registerWithRegistrar:registrar];
}
@end
