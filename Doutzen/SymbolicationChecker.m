//
//  SymbolicationChecker.m
//  Doutzen
//
//  Created by Niels Mouthaan on 26-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SymbolicationChecker.h"
#import "StatusBarController.h"
#import "StandardPaths.h"
#import <AVFoundation/AVFoundation.h>

@interface SymbolicationChecker()

@property (strong) NSTimer *timer;
@property (strong, nonatomic) NSSpeechSynthesizer *speechSynthesizer;

@end

@implementation SymbolicationChecker

static SymbolicationChecker *sharedChecker = nil;

+ (SymbolicationChecker*)sharedChecker
{
    @synchronized (self) {
        if (sharedChecker == nil) {
            sharedChecker = [[SymbolicationChecker alloc] init];
        }
    }
    return sharedChecker;
}

+ (BOOL)configurationValid
{
    if(![Configuration quincyKitHoshPrefixedWithAuthenticationDetails:NO]) {
        [SymbolicationChecker sharedChecker].error = @"Configuration error";
        [[StatusBarController sharedStatusBarController] changeMenuIconStateTo:MenuIconStateError];
        return NO;
    } else {
        return YES;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        
        _speechSynthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:kVoiceOverVoice];
        if(_speechSynthesizer == nil) {
            ALog(@"Voice %@ does not exist, using default voice", kVoiceOverVoice);
            _speechSynthesizer = [[NSSpeechSynthesizer alloc] init];
        }
        
    }
    return self;
}

- (BOOL)schedulerIsActive
{
    if(_timer && [_timer isValid]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startAutomaticallyCheckingForCrashLogs
{
    if([self schedulerIsActive]) {
        [self stopAutomaticallyCheckingForCrashLogs];
    }
    if([[Configuration checkEvery] integerValue] == 0) {
        return;
    }
    NSTimeInterval checkEvery = ([[Configuration checkEvery] integerValue] * 60);
    _timer = [NSTimer scheduledTimerWithTimeInterval:checkEvery target:self selector:@selector(checkForCrashLogsInBackground) userInfo:nil repeats:YES];
    [_timer fire];
    DLog(@"Automatically checking for crash logs every %@ minute(s)", [Configuration checkEvery]);
}

- (void)stopAutomaticallyCheckingForCrashLogs
{
    [_timer invalidate];
    DLog(@"Stopped automatically checking for crash logs");
}

- (void)checkForCrashLogsInBackground
{
    if(_isChecking) {
        DLog(@"Already checking");
        return;
    }
    [[StatusBarController sharedStatusBarController] changeMenuIconStateTo:MenuIconStateWorking];
    _error = @"Checking...";
    [self performSelectorInBackground:@selector(checkForCrashLogs) withObject:nil];
}

- (void)checkForCrashLogs
{
    NSAssert([SymbolicationChecker configurationValid], @"QuincyKit configuration is invalid");
    NSAssert([NSThread isMainThread] == NO, @"checkForCrashLogs should not be called on the main thread");
    
    // Initialization
    NSHTTPURLResponse *response = nil; NSError *error = nil; NSString *responseString = nil;
    
    // First retrieve the todo list
    NSURL *quincyToDoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[Configuration quincyKitHoshPrefixedWithAuthenticationDetails:YES] absoluteString], kQuincyKitTodoURLSuffix]];
    responseString = [Utilities synchronousRequestWithURL:quincyToDoURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData returningResponse:&response error:&error];
    if(error) {
        [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithError:) withObject:error waitUntilDone:NO];
        return;
    }
    
    // Loop through crashes in todo list
    NSArray *crashIDs = [responseString componentsSeparatedByString:kQuincyKitTodoSeperator];
    
    NSMutableDictionary *symbolicatedCrashes = [NSMutableDictionary dictionary];
    
    for(id crashIDObj in crashIDs) {
        
        // Validate and format number
        if([crashIDObj length] == 0) {
            continue;
        }
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:kCFNumberFormatterNoStyle];
        NSNumber *crashID = [formatter numberFromString:crashIDObj];
        
        // Get crash data
        response = nil; error = nil; responseString = nil;
        NSURL *quincyCrashURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [[Configuration quincyKitHoshPrefixedWithAuthenticationDetails:YES] absoluteString], kQuincyKitCrashURLSuffix, crashID]];
        responseString = [Utilities synchronousRequestWithURL:quincyCrashURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData returningResponse:&response error:&error];
        if(error) {
            [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        // Try to fetch name of application
        __block NSString *appName = nil;
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kAppNameRegex options:NSRegularExpressionCaseInsensitive error:&error];
        [regex enumerateMatchesInString:responseString options:0 range:NSMakeRange(0, [responseString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            if([match numberOfRanges] >= 3) {
                NSRange range = [match rangeAtIndex:2];
                appName = [responseString substringWithRange:range];
                
                // Make sure the app name is not too long
                if([appName length] > kAppNameMaxLength) {
                    appName = [appName substringToIndex:kAppNameMaxLength];
                }
            }
        }];
        
        if(appName) {
            
            // Try to fetch version of application
            __block NSString *versionNumber = nil;
            error = NULL;
            regex = [NSRegularExpression regularExpressionWithPattern:kVersionNumberRegex options:NSRegularExpressionCaseInsensitive error:&error];
            [regex enumerateMatchesInString:responseString options:0 range:NSMakeRange(0, [responseString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                if([match numberOfRanges] >= 3) {
                    NSRange range = [match rangeAtIndex:2];
                    versionNumber = [responseString substringWithRange:range];
                    
                    // Make sure the version name is not too long
                    if([versionNumber length] > kVersionNameMaxLength) {
                        versionNumber = [versionNumber substringToIndex:kVersionNameMaxLength];
                    }
                }
            }];
            
            // Combine app and version number if version number can be found
            if(versionNumber) {
                appName = [NSString stringWithFormat:@"%@ %@ %@", appName, NSLocalizedString(@"TextToSpeechVersion", @""), versionNumber];
            }
            
        } else {
            appName = NSLocalizedString(@"TextToSpeechUnknown", "");
        }
        
        //Save crash data
        error = nil;
        NSString *filePath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.crash", [crashID integerValue]]];
        BOOL succeed = [responseString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!succeed){
            ALog(@"Failed saving crash data at %@", filePath);
            [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithErrorMessage:) withObject:NSLocalizedString(@"QuincyKitFileError", @"") waitUntilDone:NO];
            return;
        }
        DLog(@"Saved crash data at %@", filePath);
        
        // Symbolicate crash data using symbolicatecrash.pl
        NSString *filePathSymbolicated = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li-symbolicated.crash", [crashID integerValue]]];
        NSString *launchPad = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:kResourceSymbolicator];
        if([[NSFileManager defaultManager] fileExistsAtPath:launchPad]) {
            NSTask *symbolicateTask = [[NSTask alloc] init];
            symbolicateTask.launchPath = launchPad;
            symbolicateTask.arguments = [NSArray arrayWithObjects:@"-o", filePathSymbolicated, filePath, nil];
            [symbolicateTask launch];
            [symbolicateTask waitUntilExit];
        } else {
            ALog(@"Symbolicater cannot be found at path  %@", launchPad);
            [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithErrorMessage:) withObject:NSLocalizedString(@"QuincyKitFileError", @"") waitUntilDone:NO];
            return;
        }
        
        // Update QuincyKit with the symbolicated info
        response = nil; error = nil; responseString = nil;
        NSString *symbolicatedDataString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePathSymbolicated] encoding:NSUTF8StringEncoding];
        NSURL *quincySymbolicatedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[Configuration quincyKitHoshPrefixedWithAuthenticationDetails:YES] absoluteString], kQuincyKitUpdateURLSuffix]];
        NSString *httpBody = [NSString stringWithFormat:@"id=%li&log=%@", [crashID integerValue], symbolicatedDataString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:quincySymbolicatedURL];
        [request setTimeoutInterval:kNetworkTimeOut];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[httpBody  dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"Request [%@: %@]: %@", [request HTTPMethod], [[request URL] absoluteString], ([request HTTPBody] ? [NSString stringWithUTF8String:[[request HTTPBody] bytes]] : @""));
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(error) {
            ALog(@"Request error: %@", [error localizedDescription]);
            [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithError:) withObject:error waitUntilDone:NO];
            return;
        }
        responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        DLog(@"Response: %@", responseString);
        
        if([responseString hasSuffix:kQuincyKitSuccessMessage] == NO) {
            ALog(@"QuincyKit could not update the crash log");
            [self performSelectorOnMainThread:@selector(checkForCrashLogsFailedWithErrorMessage:) withObject:NSLocalizedString(@"QuincyKitUpdateError", @"") waitUntilDone:NO];
            return;
        }
        
        DLog(@"Updated crash with crash ID %li with symbolicated information", [crashID integerValue]);
        
        NSNumber *noOfCrashesForThisApp = [symbolicatedCrashes objectForKey:appName];
        if(noOfCrashesForThisApp) {
            noOfCrashesForThisApp = [NSNumber numberWithInteger:([noOfCrashesForThisApp integerValue] + 1)];
        } else {
            noOfCrashesForThisApp = [NSNumber numberWithInteger:1];
        }
        [symbolicatedCrashes setObject:noOfCrashesForThisApp forKey:appName];
    }
    [self performSelectorOnMainThread:@selector(checkForCrashLogsFinishedWithNumberOfCrashes:) withObject:symbolicatedCrashes waitUntilDone:NO];
}

- (void)checkForCrashLogsFailedWithErrorMessage:(NSString*)message
{
    _error = message;
    [[StatusBarController sharedStatusBarController] changeMenuIconStateTo:MenuIconStateError];
    _isChecking = NO;
    
    // Play sound if requested
    if([Configuration playSounds]) {
        [_speechSynthesizer startSpeakingString:NSLocalizedString(@"TextToSpeechError", "")];
    }
}

- (void)checkForCrashLogsFailedWithError:(NSError*)error
{
    NSLog(@"ERROR: %li", error.code);
    if(error.code == kCFURLErrorUnsupportedURL || error.code ==  kCFURLErrorCannotFindHost || error.code == kCFURLErrorCannotConnectToHost || error.code ==  kCFURLErrorBadURL) {
        [self checkForCrashLogsFailedWithErrorMessage:NSLocalizedString(@"ErrorConnectionError", "")];
    } else if (error.code == kCFURLErrorUserCancelledAuthentication) {
        [self checkForCrashLogsFailedWithErrorMessage:NSLocalizedString(@"ErrorAuthenticationError", "")];
    } else {
        [self checkForCrashLogsFailedWithErrorMessage:NSLocalizedString(@"ErrorUnknownError", "")];
    }
}

- (void)checkForCrashLogsFinishedWithNumberOfCrashes:(NSDictionary*)crashes
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kDefaultsKeyLastSynced];
    if([crashes count] > 0) {
        [[StatusBarController sharedStatusBarController] changeMenuIconStateTo:MenuIconStateCrash];
    } else {
        [[StatusBarController sharedStatusBarController] changeMenuIconStateTo:MenuIconStateNormal];
    }
    _error = nil;
    _isChecking = NO;
    
    // Play sound if requested
    if([crashes count] > 0 && [Configuration playSounds]) {
        
        __block NSString *textToSpeech = @"";
        [crashes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([obj integerValue] == 1) {
                textToSpeech = [NSString stringWithFormat:@"%@. %@ %@ %@", textToSpeech, obj, NSLocalizedString(@"TextToSpeechOneErrorFound", @""), key];
            } else {
                textToSpeech = [NSString stringWithFormat:@"%@. %@ %@ %@", textToSpeech, obj, NSLocalizedString(@"TextToSpeechMultipleErrorsFound", @""), key];
            }
        }];
        [_speechSynthesizer startSpeakingString:textToSpeech];
    
    }
}

@end
