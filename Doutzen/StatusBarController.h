//
//  StatusBarController.h
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "AppDelegate.h"

typedef enum {
    MenuIconStateNormal,
    MenuIconStateError,
    MenuIconStateWorking,
    MenuIconStateCrash
} MenuIconState;

@interface StatusBarController : NSObject <NSMenuDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *menu;
@property (strong, nonatomic) IBOutlet NSMenuItem *itemVisitQuincyKit;
@property (strong, nonatomic) IBOutlet NSMenuItem *itemCheckNow;
@property (strong, nonatomic) IBOutlet NSMenuItem *itemCheckedAgo;
@property (strong, nonatomic) IBOutlet NSMenuItem *itemOpenPreferences;
@property (strong, nonatomic) IBOutlet NSMenuItem *itemQuit;

+ (StatusBarController*)sharedStatusBarController;
- (IBAction)visitQuincyKit:(id)sender;
- (IBAction)checkNow:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quitApp:(id)sender;
- (void)changeMenuIconStateTo:(MenuIconState)state;

@end
