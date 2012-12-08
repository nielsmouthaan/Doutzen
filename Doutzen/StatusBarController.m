//
//  StatusBarController.m
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "StatusBarController.h"
#import "SymbolicationChecker.h"
#import "AppDelegate.h"
#import "PreferencesWindow.h"

@interface StatusBarController()

@property (strong, nonatomic) NSStatusItem *icon;
@property (strong) NSTimer *rotationTimer;
@property (assign) NSInteger rotationNumber;

@end

@implementation StatusBarController

static StatusBarController *sharedStatusBarController = nil;

+ (StatusBarController*)sharedStatusBarController
{
    @synchronized (self) {
        if (sharedStatusBarController == nil) {
            sharedStatusBarController = [[StatusBarController alloc] init];
        }
    }
    return sharedStatusBarController;
}

- (id)init
{
    if (nil != (self = [super init])) {
        // Load stuff from nib
        if (![NSBundle loadNibNamed:@"StatusBarController" owner:self]) {
            self = nil;
        } else {
            // Create menu icon
            _icon = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
            [_icon setMenu:_menu];
            [_icon setHighlightMode:YES];
            [self changeMenuIconStateTo:MenuIconStateNormal];
            
            NSDate *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyLastSynced];
            if(lastChecked) {
                [_itemCheckedAgo setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"CheckerChecked", @""), [Utilities timePassedStringForDate:lastChecked]]];
            } else {
                [_itemCheckedAgo setTitle:NSLocalizedString(@"CheckerNotCheckedYet", @"")];
            }
        }
    }
    return self;
}

- (IBAction)visitQuincyKit:(id)sender
{
    if([Configuration quincyKitHoshPrefixedWithAuthenticationDetails:NO]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[Configuration quincyKitHoshPrefixedWithAuthenticationDetails:NO] absoluteString], kQuincyKitAdminURLSuffix]]];
    } else {
        [self openPreferences:sender];
    }
}

- (IBAction)checkNow:(id)sender
{
    if([SymbolicationChecker configurationValid]) {
        [[SymbolicationChecker sharedChecker] checkForCrashLogsInBackground];
    } else {
        [self openPreferences:sender];
    }
}

- (IBAction)openPreferences:(id)sender
{
    [[PreferencesWindow sharedPreferencesWindow] show];
}

- (IBAction)quitApp:(id)sender
{
    [[NSApplication sharedApplication] terminate:sender];
}

- (void)rotateIcon
{
    _rotationNumber++;
    if(_rotationNumber >= kIconRotateSteps) {
        _rotationNumber = 0;
    }
    float degrees = _rotationNumber * (360 / kIconRotateSteps);
    NSImage *rotatedImage = [Utilities rotateImage:[NSImage imageNamed:kMenuIconNormal] byDegrees:degrees];
    [_icon setImage:rotatedImage];
}

- (void)menuWillOpen:(NSMenu *)menu {
    // Show network error if present, otherwise show last sync date
    if([SymbolicationChecker sharedChecker].error == nil) {
        NSDate *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyLastSynced];
        if(lastChecked) {
            [_itemCheckedAgo setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"CheckerChecked", @""), [Utilities timePassedStringForDate:lastChecked]]];
        } else {
            [_itemCheckedAgo setTitle:NSLocalizedString(@"CheckerNotCheckedYet", @"")];
        }
    } else {
        [_itemCheckedAgo setTitle:[NSString stringWithFormat:@"%@", [SymbolicationChecker sharedChecker].error]];
    }
}

- (void)changeMenuIconStateTo:(MenuIconState)state
{
    [_rotationTimer invalidate];
    if(state == MenuIconStateNormal) {
        [_icon setImage:[NSImage imageNamed:kMenuIconNormal]];
        [_icon setAlternateImage:[NSImage imageNamed:kMenuIconHighlighted]];
    } else if(state == MenuIconStateError) {
        [_icon setImage:[NSImage imageNamed:kMenuIconError]];
        [_icon setAlternateImage:[NSImage imageNamed:kMenuIconHighlighted]];
    } else if(state == MenuIconStateWorking) {
        [_icon setImage:[NSImage imageNamed:kMenuIconNormal]];
        [_icon setAlternateImage:[NSImage imageNamed:kMenuIconHighlighted]];
        _rotationTimer = [NSTimer scheduledTimerWithTimeInterval:kIconRotateInterval target:self selector:@selector(rotateIcon) userInfo:nil repeats:YES];
    } else if(state == MenuIconStateCrash) {
        [_icon setImage:[NSImage imageNamed:kMenuIconCrash]];
        [_icon setAlternateImage:[NSImage imageNamed:kMenuIconHighlighted]];
    }
}

@end
