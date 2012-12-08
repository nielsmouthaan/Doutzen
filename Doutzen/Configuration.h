//
//  Configuration.h
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject

+ (NSURL*)quincyKitHoshPrefixedWithAuthenticationDetails:(BOOL)prefixWithAuthenticationDetails;
+ (NSString*)quincyKitUsername;
+ (NSString*)quincyKitPassword;
+ (NSNumber*)checkEvery;
+ (BOOL)playSounds;

@end
