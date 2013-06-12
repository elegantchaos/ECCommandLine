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
@property (strong, nonatomic, readwrite) NSArray* arguments;
@property (strong, nonatomic) NSDictionary* info;
@property (assign, nonatomic) NSUInteger minimumArguments;
@property (assign, nonatomic) NSUInteger maximumArguments;

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
		NSArray* arguments = info[@"arguments"];
		for (NSDictionary* argument in arguments)
		{
			++_maximumArguments;
			if (![argument[@"optional"] boolValue])
			{
				++_minimumArguments;
			}
		}
		self.arguments = arguments;
	}

	return self;
}

- (NSString*)help
{
	return self.info[@"help"];
}

- (NSString*)usage
{
	NSMutableString* description = [[NSMutableString alloc] init];
	for (NSDictionary* argument in self.arguments)
	{
		NSString* string = [NSString stringWithFormat:@"<%@>", argument[@"description"]];
		if ([argument[@"optional"] boolValue])
		{
			string = [NSString stringWithFormat:@"{ %@ }", string];
		}

		[description appendFormat:@"%@ ", string];
	}

	NSString* result = [NSString stringWithFormat:@"%@ %@ # %@", self.name, description, self.help];

	return result;
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

- (ECCommandLineResult)validateArguments:(NSMutableArray*)arguments
{
	NSUInteger count = [arguments count];
	ECCommandLineResult result = (count >= self.minimumArguments) ? ECCommandLineResultOK : ECCommandLineResultMissingArguments;

	return result;
}

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine processCommands:(NSMutableArray*)commands
{
	// TODO: handle sub-commands here

	NSMutableArray* arguments = commands;
	ECCommandLineResult result = [self validateArguments:arguments];

	if (result == ECCommandLineResultOK)
	{
		result = [self engine:engine willProcessWithArguments:arguments];
	}
	else
	{
		[engine outputError:nil format:@"Missing arguments for command ‘%@’.\n", self.name];
	}

	if (result == ECCommandLineResultOK)
	{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			ECCommandLineResult commandResult = [self engine:engine didProcessWithArguments:arguments];
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
	NSLog(@"No implementation for command %@ (%@)", self.name, [self class]);

	return ECCommandLineResultNotImplemented;
}

@end
