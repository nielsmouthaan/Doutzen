//
//  Utilities.m
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSImage*)rotateImage:(NSImage*)orig byDegrees:(float)deg {
    NSSize size = [orig size];
    NSSize maxSize;
    maxSize = NSMakeSize(MAX(size.width, size.height), MAX(size.width, size.height));
    NSAffineTransform *rot = [NSAffineTransform transform];
    [rot rotateByDegrees:deg];
    NSAffineTransform *center = [NSAffineTransform transform];
    [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
    [rot appendTransform:center];
    NSImage *image = [[NSImage alloc] initWithSize:maxSize];
    [image lockFocus];
    [rot concat];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
    [orig drawAtPoint:corner fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [image unlockFocus];
    return image;
}

+ (NSString*)timePassedStringForDate:(NSDate*)date {
    if(date == nil) {
        return @"never before";
    }
    NSDate *now = [NSDate date];
    double deltaSeconds = abs([date timeIntervalSinceDate:now]);
    if(deltaSeconds < 3) {
        return @"a few seconds ago";
    } else if(deltaSeconds < 60) {
        return [NSString stringWithFormat:@"%i seconds ago", (int)floor(deltaSeconds)];
    } else if(deltaSeconds < (60 * 2)) {
        return @"one minute ago";
    } else if(deltaSeconds < (60 * 60)) {
        return [NSString stringWithFormat:@"%i minutes ago", (int)floor(deltaSeconds / 60)];
    } else if(deltaSeconds < (60 * 60 * 2)) {
        return @"one hour ago";
    } else if(deltaSeconds < (60 * 60 * 24)) {
        return [NSString stringWithFormat:@"%i hours ago", (int)floor(deltaSeconds / (60 * 60))];
    } else if(deltaSeconds < (60 * 60 * 24 * 2)) {
        return @"yesterday";
    } else if(deltaSeconds < (60 * 60 * 24 * 7)) {
        return [NSString stringWithFormat:@"%i days ago", (int)floor(deltaSeconds / (60 * 60 * 24))];
    } else if(deltaSeconds < (60 * 60 * 24 * 14)) {
        return @"last week";
    } else if(deltaSeconds < (60 * 60 * 24 * 31)) {
        return [NSString stringWithFormat:@"%i weeks ago", (int)floor(deltaSeconds / (60 * 60 * 24 * 7))];
    } else if(deltaSeconds < (60 * 60 * 24 * 61)) {
        return @"last month";
    } else if(deltaSeconds < (60 * 60 * 24 * 365.25)) {
        return [NSString stringWithFormat:@"%i months ago", (int)floor(deltaSeconds / (60 * 60 * 24 * 30))];
    } else if(deltaSeconds < (60 * 60 * 24 * 731)) {
        return @"last year";
    } else {
        return [NSString stringWithFormat:@"%i years ago", (int)floor(deltaSeconds / (60 * 60 * 24 * 365))];
    }
}

+ (NSDate*)convertToGmt:(NSDate*)date {
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSTimeInterval gmtTimeInterval = [date timeIntervalSinceReferenceDate] - timeZoneOffset;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
}

+ (int)indexFromSliderWithValue:(float)value withItems:(NSArray*)items {
    NSAssert([items count] > 0, @"Array with items need to contain at least one item");
    float itemSpace = 100 / [items count];
    int item = floor(value / itemSpace);
    if(item >= [items count]) {
        item--;
    }
    return item;
}

+ (float)floatValueForSliderWithNumber:(NSNumber*)number withItems:(NSArray*)items {
     NSAssert([items count] > 0, @"Array with items need to contain at least one item");
    float itemSpace = 100 / [items count];
    int index = 0;
    for(NSNumber *item in items) {
        if([item isEqualToNumber:number]) {
            break;
        }
        index++;
    }
    float value = index * itemSpace + (itemSpace / 2);
    if(value < 0 || index == 0) {
        value = 0;
    } else if(value > 100 || index == ([items count] - 1)) {
        value = 100;
    }
    return value;
}

+ (NSString*)synchronousRequestWithURL:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:kNetworkTimeOut];
    DLog(@"Request [%@: %@]: %@", [request HTTPMethod], [[request URL] absoluteString], ([request HTTPBody] ? [NSString stringWithUTF8String:[[request HTTPBody] bytes]] : @""));
    NSData *responseData =  [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    if(*error) {
        ALog(@"Request error: %@", [*error localizedDescription]);
        return nil;
    } else {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        DLog(@"Response: %@", responseString);
        return responseString;
    }
}

@end
