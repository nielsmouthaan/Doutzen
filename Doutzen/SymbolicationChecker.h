//
//  SymbolicationChecker.h
//  Doutzen
//
//  Created by Niels Mouthaan on 26-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SymbolicationChecker : NSObject

@property (strong, nonatomic) NSString *error;
@property (assign, readonly) BOOL isChecking;
@property (assign, readonly) BOOL schedulerIsActive;

+ (SymbolicationChecker*)sharedChecker;
+ (BOOL)configurationValid;
- (void)startAutomaticallyCheckingForCrashLogs;
- (void)stopAutomaticallyCheckingForCrashLogs;
- (void)checkForCrashLogsInBackground;

@end
