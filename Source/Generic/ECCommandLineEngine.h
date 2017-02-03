// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineResult.h"
#import "ECCommandLineEngineDelegate.h"

//ECDeclareDebugChannel(CommandLineEngineChannel);

@class ECCommandLineCommand;
@class ECCommandLineOption;

@interface ECCommandLineEngine : NSObject

@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic) id<ECCommandLineEngineDelegate> delegate;

- (id)initWithDelegate:(id<ECCommandLineEngineDelegate>)delegate;

- (ECCommandLineResult)processArguments:(int)argc argv:(const char **)argv;

- (void)showUsage;
- (void)outputDescription:(NSString*)description;
- (void)outputFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 Makes a new NSError and then calls `outputError:`.
 This can be used to wrap up an underlying error by passing it in with the info dictionary like so: @{ NSUnderlyingErrorKey : underlyingError }.
 */

- (void)outputErrorWithDomain:(NSString*)domain code:(NSUInteger)code info:(NSDictionary*)info format:(NSString *)format, ... NS_FORMAT_FUNCTION(4,5);

/**
 Output an error to stderr.
 
 This can be a custom error we made, or something passed along to us by a system routine.
 If there error contains a localized description or localized reason, then that is logged.
 If it contains an underlying error, that's also logged.
 In either case, the error domain and code are also logged.
 */

- (void)outputError:(NSError*)error;
- (void)outputInfo:(id)info withKey:(NSString*)key;
- (void)openInfoGroupWithKey:(NSString*)key;
- (void)closeInfoGroup;
- (NSDictionary*)info;

- (id)optionForKey:(NSString*)key;
- (BOOL)boolOptionForKey:(NSString*)key;
- (CGFloat)doubleOptionForKey:(NSString*)key;
- (NSString*)stringOptionForKey:(NSString*)key;
- (NSURL*)urlOptionForKey:(NSString*)key defaultingToWorkingDirectory:(BOOL)defaultingToWorkingDirectory;
- (NSArray*)arrayOptionForKey:(NSString*)key separator:(NSString*)separator;

- (ECCommandLineCommand*)commandWithName:(NSString*)name;
- (ECCommandLineOption*)optionWithName:(NSString *)name;
- (NSUInteger)paddingLength;

- (void)exitWithResult:(ECCommandLineResult)result;

+ (void)addCommandNamed:(NSString*)mainName withInfo:(NSDictionary*)info toDictionary:(NSMutableDictionary*)dictionary parentCommand:(ECCommandLineCommand*)parentCommand;
+ (NSArray*)commandsInDisplayOrder:(NSDictionary*)commands;

@end
