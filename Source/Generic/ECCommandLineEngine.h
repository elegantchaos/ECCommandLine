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

@interface ECCommandLineEngine : NSObject <ECIODelegate>

@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic) id<ECCommandLineEngineDelegate> delegate;

- (id)initWithDelegate:(id<ECCommandLineEngineDelegate>)delegate;

- (ECCommandLineResult)processArguments:(int)argc argv:(const char **)argv;

- (void)showUsage;
- (void)outputDescription:(NSString*)description;

- (NSDictionary*)info;

- (ECCommandLineCommand*)commandWithName:(NSString*)name;
- (ECCommandLineOption*)optionWithName:(NSString *)name;
- (NSUInteger)paddingLength;

- (void)exitWithResult:(ECCommandLineResult)result;

+ (void)addCommandNamed:(NSString*)mainName withInfo:(NSDictionary*)info toDictionary:(NSMutableDictionary*)dictionary parentCommand:(ECCommandLineCommand*)parentCommand;
+ (NSArray*)commandsInDisplayOrder:(NSDictionary*)commands;

@end
