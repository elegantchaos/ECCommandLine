// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineResult.h"

ECDeclareDebugChannel(CommandLineEngineChannel);

@class ECCommandLineCommand;
@class ECCommandLineOption;

@interface ECCommandLineEngine : NSObject

@property (strong, nonatomic, readonly) NSString* name;

- (ECCommandLineResult)processArguments:(int)argc argv:(const char **)argv;

- (void)showUsage;
- (void)outputFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)outputError:(NSError*)error format:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);
- (id)optionForKey:(NSString*)key;
- (ECCommandLineCommand*)commandWithName:(NSString*)name;
- (ECCommandLineOption*)optionWithName:(NSString *)name;
- (NSUInteger)paddingLength;

@end