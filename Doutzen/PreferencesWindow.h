//
//  PreferencesWindow.h
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindow : NSObject

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *quincyKitPasswordTextView;
@property (weak) IBOutlet NSTextField *checkEveryLabel;
@property (weak) IBOutlet NSView *playSoundOnCrashDropView;
@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSButton *openAtLoginCheckbox;

+ (PreferencesWindow*)sharedPreferencesWindow;
+ (NSArray*)possibleCheckEveryTimes;
- (IBAction)checkEveryValueChanged:(id)sender;
- (void)show;
- (IBAction)addLoginItem:(id)sender;

@end
