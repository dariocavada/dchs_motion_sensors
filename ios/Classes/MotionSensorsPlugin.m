#import "MotionSensorsPlugin.h"
#if __has_include(<dchs_motion_sensors/dchs_motion_sensors-Swift.h>)
#import <dchs_motion_sensors/dchs_motion_sensors-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dchs_motion_sensors-Swift.h"
#endif

@implementation MotionSensorsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMotionSensorsPlugin registerWithRegistrar:registrar];
}
@end
