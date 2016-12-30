//
//  Logcat.h
//  Logcat
//
//  Created by Chris Kap on 12/9/16.
//  Copyright © 2016 Chris Kap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLumberjack/CocoaLumberjack.h"
//! Project version number for Logcat.
FOUNDATION_EXPORT double LogcatVersionNumber;

//! Project version string for Logcat.
FOUNDATION_EXPORT const unsigned char LogcatVersionString[];

#ifdef DEBUG
#   define DLog(fmt, ...) DDLogDebug((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) DDLogDebug((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
// In this header, you should import all the public headers of your framework using statements like #import <Logcat/PublicHeader.h>

@interface Logcat : NSObject
@property (nonatomic, strong, readonly) UIAlertController* infoAlert;
@property (nonatomic, strong) UIViewController* fileViewController;
@property (nonatomic, strong) id<DDLogFileManager> logFileManager;
// singlton logcat
+ (instancetype) sharedInstance;

- (void) start;

- (void) redirectDefaultLogToFile;
//- (UIViewController*) instantFilesViewController;
@end
