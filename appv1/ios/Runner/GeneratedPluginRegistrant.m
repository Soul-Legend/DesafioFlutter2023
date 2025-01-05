//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<fast_rsa/FastRsaPlugin.h>)
#import <fast_rsa/FastRsaPlugin.h>
#else
@import fast_rsa;
#endif

#if __has_include(<flutter_blue/FlutterBluePlugin.h>)
#import <flutter_blue/FlutterBluePlugin.h>
#else
@import flutter_blue;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FastRsaPlugin registerWithRegistrar:[registry registrarForPlugin:@"FastRsaPlugin"]];
  [FlutterBluePlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterBluePlugin"]];
}

@end
