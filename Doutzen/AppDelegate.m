//
//  AppDelegate.m
//  Doutzen
//
//  Created by Niels Mouthaan on 28-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusBarController.h"
#import "PreferencesWindow.h"
#import "SymbolicationChecker.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    // Register defaults
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kFileInitialConfiguration ofType:@"plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:plistPath]];
    
    // Initialize and show status bar icon
    [StatusBarController sharedStatusBarController];
    
    // Check if our configuration is valid, otherwise show preference window and show warning
    if([SymbolicationChecker configurationValid] == NO) {
        [[PreferencesWindow sharedPreferencesWindow] show];
    } else {
        // Configuration is valid, check if we need to start checking automatically, if so than start
        if([[Configuration checkEvery] integerValue] > 0) {
            [[SymbolicationChecker sharedChecker] startAutomaticallyCheckingForCrashLogs];
        }
    }
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if([[SymbolicationChecker sharedChecker] schedulerIsActive]) {
        [[SymbolicationChecker sharedChecker] stopAutomaticallyCheckingForCrashLogs];
    }
}

@end
