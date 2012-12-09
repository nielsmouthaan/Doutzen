//
//  Configuration.m
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Configuration.h"
#import "PDKeychainBindings.h"
#import "PDKeychainBindingsController.h"
#import "PreferencesWindow.h"

@implementation Configuration

+ (NSURL*)quincyKitHoshPrefixedWithAuthenticationDetails:(BOOL)prefixWithAuthenticationDetails
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsQuincyKitHost];
    if(obj && [obj isKindOfClass:[NSString class]] && [obj hasPrefix:@"http://"] == NO && [obj hasPrefix:@"https://"] == NO) {
        obj = [NSString stringWithFormat:@"http://%@", obj];
    }
    if(obj && [obj isKindOfClass:[NSString class]] && [NSURL URLWithString:obj]) {
        if([Configuration quincyKitUsername] && [Configuration quincyKitUsername] && prefixWithAuthenticationDetails) {
            obj = [obj stringByReplacingOccurrencesOfString:@"http://" withString:[NSString stringWithFormat:@"http://%@:%@@", [Configuration quincyKitUsername], [Configuration quincyKitPassword]]];
            obj = [obj stringByReplacingOccurrencesOfString:@"https://" withString:[NSString stringWithFormat:@"https://%@:%@@", [Configuration quincyKitUsername], [Configuration quincyKitPassword]]];
        }
    
	return [NSURL URLWithString:[obj stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];    
    } else {
        return nil;
    }
}

+ (NSString*)quincyKitUsername
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsQuincyKitUsername];
    if(obj && [obj isKindOfClass:[NSString class]]) {
        return obj;
    } else {
        return @"";
    }
}

+ (NSString*)quincyKitPassword
{
    id obj = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kDefaultsQuincyKitPassword];
    if(obj && [obj isKindOfClass:[NSString class]]) {
        return obj;
    } else {
        return @"";
    }
}

+ (NSNumber*)checkEvery
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsCheckEvery];
    if(obj && [obj isKindOfClass:[NSNumber class]]) {
        return [[PreferencesWindow possibleCheckEveryTimes] objectAtIndex:[Utilities indexFromSliderWithValue:[obj floatValue] withItems:[PreferencesWindow possibleCheckEveryTimes]]];
    } else {
        return [NSNumber numberWithInt:0];
    }
}

+ (BOOL)playSounds
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsPlaySounds];
    if(obj && [obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    } else {
        return NO;
    }
}

@end
