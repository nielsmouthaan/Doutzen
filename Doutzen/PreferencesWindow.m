//
//  PreferencesWindow.m
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PreferencesWindow.h"
#import "PDKeychainBindingsController.h"
#import "SymbolicationChecker.h"

@interface PreferencesWindow()

@property (strong) NSTimer *checkEveryApplyTimer;

@end

@implementation PreferencesWindow

static PreferencesWindow *sharedPreferencesWindow = nil;

+ (PreferencesWindow*)sharedPreferencesWindow
{
    @synchronized (self) {
        if (sharedPreferencesWindow == nil) {
            sharedPreferencesWindow = [[PreferencesWindow alloc] init];
        }
    }
    return sharedPreferencesWindow;
}

+ (NSArray*)possibleCheckEveryTimes
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:5], [NSNumber numberWithInt:15], [NSNumber numberWithInt:60], nil];
}

- (id)init
{
    if (nil != (self = [super init])) {
        
        NSAssert([[PreferencesWindow possibleCheckEveryTimes] count] > 0, @"No values for possibleCheckEveryTimes");
        
        // Load stuff from nib
        if (![NSBundle loadNibNamed:@"PreferencesWindow" owner:self]) {
            self = nil;
        } else {
            
            [_window setLevel:kCGPopUpMenuWindowLevel];
            
            // Set version number
            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
            [_versionLabel setStringValue:[NSString stringWithFormat:@"v%@.%@", [infoDict objectForKey:@"CFBundleVersion"], [NSNumber numberWithInt:([[infoDict objectForKey:@"CFBuildNumber"] intValue] + 1)]]];
            
            // Bind password field with keychain item
            [_quincyKitPasswordTextView bind:@"value"
                       toObject:[PDKeychainBindingsController sharedKeychainBindingsController]
                    withKeyPath:[NSString stringWithFormat:@"values.%@", kDefaultsQuincyKitPassword]
                        options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:@"NSContinuouslyUpdatesValue"]];
        }
    }
    return self;
}

- (void)updateCheckEveryLabel
{
    NSString *syncText = NSLocalizedString(@"PreferencesManualOnly", @"");
    if([[Configuration checkEvery] integerValue] == 1) {
        syncText = [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"GeneralMinute", @"")];
    } else if([[Configuration checkEvery] integerValue] > 1) {
        syncText = [NSString stringWithFormat:@"%@ %@", [Configuration checkEvery], NSLocalizedString(@"GeneralMinutes", @"")];
    }
    if([_checkEveryLabel.stringValue isEqualToString:syncText] == NO) {
        [_checkEveryLabel setStringValue:syncText];
        [_checkEveryApplyTimer invalidate];
        _checkEveryApplyTimer = [NSTimer scheduledTimerWithTimeInterval:kPreferencesCheckEveryApplyAfter target:self selector:@selector(applyNewCheckEveryValue) userInfo:nil repeats:NO];
    }
}

- (void)applyNewCheckEveryValue
{
    if([[Configuration checkEvery] integerValue] == 0 && [[SymbolicationChecker sharedChecker] schedulerIsActive]) {
        [[SymbolicationChecker sharedChecker] stopAutomaticallyCheckingForCrashLogs];
    } else if([[Configuration checkEvery] integerValue] > 0) {
        [[SymbolicationChecker sharedChecker] stopAutomaticallyCheckingForCrashLogs];
        [[SymbolicationChecker sharedChecker] startAutomaticallyCheckingForCrashLogs];
    }
}

- (IBAction)checkEveryValueChanged:(id)sender
{
    [self updateCheckEveryLabel];
}

- (void)show
{
    [self updateCheckEveryLabel];
    [_window makeKeyAndOrderFront:nil];
}

- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath
{
 	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
 	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, thePath, NULL, NULL);
 	if (item)
 		CFRelease(item);
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath
{
 	UInt32 seedValue;
 	
 	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
 	// and pop it in an array so we can iterate through it to find our item.
 	NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
 	for (id item in loginItemsArray) {
 		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
 		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
 			if ([[(__bridge NSURL *)thePath path] hasPrefix:[[NSBundle mainBundle] bundlePath]])
 				LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
 		}
 	}
}

- (IBAction)addLoginItem:(id)sender
{
 	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
 	
 	// Create a reference to the shared file list.
 	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
 	
 	if (loginItems) {
 		if ([[_openAtLoginCheckbox selectedCell] state] == YES)
 			[self enableLoginItemWithLoginItemsReference:loginItems ForPath:url];
 		else
 			[self disableLoginItemWithLoginItemsReference:loginItems ForPath:url];
 	}
 	CFRelease(loginItems);
}

@end
