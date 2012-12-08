//
//  Defines.h
//  Doutzen
//
//  Created by Niels Mouthaan on 27-10-12.
//  Copyright (c) 2012. All rights reserved.
//

#define kFileInitialConfiguration           @"initialConfiguration"

#define kDefaultsKeyLastSynced              @"lastSynced"
#define kDefaultsQuincyKitHost              @"quincyKitHost"
#define kDefaultsQuincyKitUsername          @"quincyKitUsername"
#define kDefaultsQuincyKitPassword          @"quincyKitPassword"
#define kDefaultsCheckEvery                 @"checkEvery"
#define kDefaultsPlaySounds                 @"playSounds"

#define kValueFormatterMustUseHttpOrHttps   @"mustUseHttpOrHttps"

#define kKeychainService                    @"Doutzen"

#define kIconRotateInterval                 0.03
#define kIconRotateSteps                    30

#define kNetworkTimeOut                     30

#define kMenuIconNormal                     @"menuIconNormal"
#define kMenuIconError                      @"menuIconError"
#define kMenuIconHighlighted                @"menuIconHighlighted"
#define kMenuIconCrash                      @"menuIconCrash"

#define kPreferencesCheckEveryApplyAfter    3

#define kQuincyKitAdminURLSuffix            @"/admin"
#define kQuincyKitTodoURLSuffix             @"/admin/symbolicate_todo.php"
#define kQuincyKitCrashURLSuffix            @"/admin/crash_get.php?id="
#define kQuincyKitUpdateURLSuffix           @"/admin/crash_update.php"
#define kQuincyKitCrashSuffix               @""
#define kQuincyKitTodoSeperator             @","
#define kQuincyKitSuccessMessage            @"success"

#define kResourceSymbolicator               @"/symbolicatecrash.pl"

#define kVoiceOverVoice                     @"com.apple.speech.synthesis.voice.Vicki"

#define kAppNameMaxLength                   50
#define kVersionNameMaxLength               20

#define kAppNameRegex                       @"\nProcess:( *)([a-zA-Z0-9\\.-_]+)"
#define kVersionNumberRegex                 @"\nVersion:( *)([a-zA-Z0-9\\.-_]+)"

