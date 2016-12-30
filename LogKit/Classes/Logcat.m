//
//  Logcat.m
//  Logcat
//
//  Created by Chris Kap on 12/9/16.
//  Copyright © 2016 Chris Kap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logcat.h"
#import "LCLogFilesTableViewController.h"

@interface LogcatLogFileManager : DDLogFileManagerDefault

@end

@implementation LogcatLogFileManager

- (NSString *)newLogFileName {
    NSDateFormatter *dateFormatter = [self performSelector:@selector(logFileDateFormatter)];
    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@.log", formattedDate];
}

- (BOOL)isLogFile:(NSString *)fileName {
    return YES;
}

@end

@implementation Logcat
+ (instancetype) sharedInstance {
    static Logcat* inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[Logcat alloc] init];
    });
    return inst;
}

- (instancetype) init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) start {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    if(!self.logFileManager) {
        NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
        NSString* logDirectory = [docsDir stringByAppendingString:@"/Log"];
        self.logFileManager = [[LogcatLogFileManager alloc] initWithLogsDirectory:logDirectory];
    }
    
    [DDLog addLogger:[[DDFileLogger alloc] initWithLogFileManager:self.logFileManager]];
}


- (UIViewController*) fileViewController {
    if(!_fileViewController)
        _fileViewController = [[LCLogFilesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    return _fileViewController;
}

- (UIAlertController*) infoAlert {
    static UIAlertController* alert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString* text = [NSString stringWithFormat:@"\n%@\nv%@ (build %@)\n\nPowered by LogKit with ❤️", appDisplayName, majorVersion, minorVersion];

        alert = [UIAlertController alertControllerWithTitle:@"Info" message:text preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    });
    
    return alert;
}

- (void)redirectDefaultLogToFile
{
    NSLog(@"redirectNSLogToDocumentFolder");
    //如果已经连接Xcode调试则不输出到文件
#ifndef DEBUG
    if(isatty(STDOUT_FILENO)) {
        return;
    }
#endif
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString* header = [NSString stringWithFormat:@"[%@] ver: %@ (build %@)\n", appDisplayName, majorVersion, minorVersion ];

    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
//    [self logBasicInfo];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
    
    //把错误日志发送到邮箱
    //    NSString *urlStr = [NSString stringWithFormat:@"mailto://test@163.com?subject=bug报告&body=感谢您的配合!
    
    
    //    错误详情:
    //    %@",crashString ];
    //    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    [[UIApplication sharedApplication] openURL:url];
}

- (void) logBasicInfo {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    NSLog(@"[%@] ver: %@ (build %@)\n", appDisplayName, majorVersion, minorVersion);
}

@end
