//
//  Utilities.h
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSImage*)rotateImage:(NSImage*)orig byDegrees:(float)deg;
+ (NSString*)timePassedStringForDate:(NSDate*)date;
+ (NSDate*)convertToGmt:(NSDate*)date;
+ (int)indexFromSliderWithValue:(float)value withItems:(NSArray*)items;
+ (float)floatValueForSliderWithNumber:(NSNumber*)number withItems:(NSArray*)items;
+ (NSString*)synchronousRequestWithURL:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end
