//
//  ECCommandLineCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineCommand.h"
#import "ECCommandLineMissingClassCommand.h"

@interface ECCommandLineCommand()

@property (strong, nonatomic, readwrite) NSString* name;
@property (strong, nonatomic) NSDictionary* info;

@end

@implementation ECCommandLineCommand

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info
{
	Class class = nil;
	NSString* className = info[@"class"];
	if (className)
		class = NSClassFromString(className);

	if (!class)
		class = [ECCommandLineMissingClassCommand class];

	ECCommandLineCommand* command = [[class alloc] initWithName:name info:info];

	return command;
}

- (id)initWithName:(NSString*)name info:(NSDictionary*)info
{
	if ((self = [super init]) != nil)
	{
		self.name = name;
		self.info = info;
	}

	return self;
}

- (NSString*)help
{
	return self.info[@"help"];
}

- (ECCommandLineArgumentMode)argumentModeForValue:(NSString*)value
{
	ECCommandLineArgumentMode result;
	if ([value isEqualToString:@"required"])
	{
		result = ECCommandLineArgumentModeRequired;
	}

	else if ([value isEqualToString:@"optional"])
	{
		result = ECCommandLineArgumentModeOptinal;
	}

	else
	{
		result = ECCommandLineArgumentModeNone;
	}

	return result;
}

- (void)enumerateArguments:(ArgumentBlock)block
{
	NSDictionary* arguments = self.info[@"arguments"];
	[arguments enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
		NSString* shortOptionInfo = info[@"short"];
		UniChar shortOption = ([shortOptionInfo length] > 0) ? [shortOptionInfo characterAtIndex:0] : 0;
		ECCommandLineArgumentMode mode = [self argumentModeForValue:info[@"mode"]];

		block(name, mode, shortOption, info);
	}];
}

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine processCommands:(NSMutableArray*)commands
{
	ECCommandLineResult result = [self engine:engine willProcessWithArguments:commands];
	if (result == 0)
	{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			ECCommandLineResult commandResult = [self engine:engine didProcessWithArguments:commands];
			if (result != ECCommandLineResultStayRunning)
			{
				exit(commandResult);
			}
		}];
	}

	return result;
}

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine willProcessWithArguments:(NSMutableArray*)arguments
{
	return ECCommandLineResultOK;
}

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	NSLog(@"couldn't process command %@ (%@)", self.name, [self class]);

	return ECCommandLineResultNotImplemented;
}

@end
