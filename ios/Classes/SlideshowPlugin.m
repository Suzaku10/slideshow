#import "SlideshowPlugin.h"
#import <slideshow/slideshow-Swift.h>

@implementation SlideshowPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSlideshowPlugin registerWithRegistrar:registrar];
}
@end
