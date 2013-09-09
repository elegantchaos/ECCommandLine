//
//  ECCommandLineCommand.h
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineResult.h"

typedef NS_ENUM(NSUInteger, ECCommandLineArgumentMode)
{
	ECCommandLineArgumentModeNone,
	ECCommandLineArgumentModeRequired,
	ECCommandLineArgumentModeOptinal,
};

typedef void(^ArgumentBlock)(NSString* name, ECCommandLineArgumentMode mode, UniChar shortOption, NSDictionary* info);

@class ECCommandLineEngine;
@interface ECCommandLineCommand : NSObject

@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) NSArray* arguments;
@property (readonly, nonatomic) ECCommandLineCommand* parentCommand;

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info parentCommand:(ECCommandLineCommand*)parentCommand;

- (void)enumerateArguments:(ArgumentBlock)block;

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine processCommands:(NSMutableArray*)commands;
- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine willProcessWithArguments:(NSMutableArray*)arguments;
- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray*)arguments;

- (NSString*)help;
- (NSString*)summaryAs:(NSString*)name parentName:(NSString*)parentName;
- (NSString*)usageAs:(NSString*)name parentName:(NSString*)parentName engine:(ECCommandLineEngine*)engine;
- (NSString*)subcommandSummaryAs:(NSString*)name;

@end
