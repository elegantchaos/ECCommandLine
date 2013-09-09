//
//  ECCommandLineCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineCommand.h"
#import "ECCommandLineMissingClassCommand.h"
#import "ECCommandLineOption.h"

@interface ECCommandLineCommand()

@property (strong, nonatomic, readwrite) NSString* name;
@property (strong, nonatomic, readwrite) NSArray* arguments;
@property (strong, nonatomic, readwrite) ECCommandLineCommand* parentCommand;
@property (strong, nonatomic) NSDictionary* subcommands;
@property (strong, nonatomic) NSDictionary* info;
@property (assign, nonatomic) NSUInteger minimumArguments;
@property (assign, nonatomic) NSUInteger maximumArguments;

@end

@implementation ECCommandLineCommand

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info parentCommand:(ECCommandLineCommand *)parentCommand
{
	Class class = nil;
	NSString* className = info[@"class"];
	if (className)
		class = NSClassFromString(className);

	if (!class)
		class = [ECCommandLineMissingClassCommand class];

	ECCommandLineCommand* command = [[class alloc] initWithName:name info:info parentCommand:parentCommand];

	return command;
}

- (id)initWithName:(NSString*)name info:(NSDictionary*)info parentCommand:(ECCommandLineCommand *)parentCommand
{
	if ((self = [super init]) != nil)
	{
		self.name = name;
		self.info = info;
		self.parentCommand = parentCommand;
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

		NSDictionary* subcommands = info[@"commands"];
		if (subcommands) {
			NSMutableDictionary* commands = [NSMutableDictionary dictionaryWithCapacity:[subcommands count]];
			for (NSString* subcommand in subcommands) {
				[ECCommandLineEngine addCommandNamed:subcommand withInfo:subcommands[subcommand] toDictionary:commands parentCommand:self];
			}
			self.subcommands = commands;
		}
	}

	return self;
}

- (NSString*)help
{
	return self.info[@"help"];
}

- (NSString*)summaryAs:(NSString*)name parentName:(NSString*)parentName
{
	NSString* fullName = parentName ? [NSString stringWithFormat:@"%@ %@", parentName, name] : name;
	NSMutableString* result = [NSMutableString stringWithString:[self ourSummaryAs:fullName]];

	for (NSString* subcommandName in self.subcommands)
	{
		ECCommandLineCommand* subcommand = self.subcommands[subcommandName];
		[result appendFormat:@"\n%@", [subcommand summaryAs:subcommandName parentName:fullName]];
	}

	return result;
}

- (NSString*)ourSummaryAs:(NSString*)name
{
	NSString* paddedName = [name stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
	NSString* result = [NSString stringWithFormat:@"%@ %@", paddedName, self.help];

	return result;
}
- (NSString*)usageAs:(NSString*)name parentName:(NSString*)parentName engine:(ECCommandLineEngine*)engine
{
	NSString* fullName = parentName ? [NSString stringWithFormat:@"%@ %@", parentName, name] : name;
	NSMutableString* result = [NSMutableString stringWithString:[self ourUsageAs:fullName engine:engine]];

	return result;
}

- (NSString*)subcommandSummaryAs:(NSString*)name
{
	NSMutableString* result = [[NSMutableString alloc] init];
	for (NSString* subcommandName in self.subcommands)
	{
		//		ECCommandLineCommand* subcommand = self.subcommands[subcommandName];
		[result appendFormat:@"\t%@ %@\n", name, subcommandName];
	}

	return result;
}

- (NSString*)ourUsageAs:(NSString*)name engine:(ECCommandLineEngine*)engine
{
	NSMutableString* description = [NSMutableString stringWithString:name];
	NSMutableString* detailed = [[NSMutableString alloc] init];

	NSUInteger paddingLength = engine.paddingLength;
	
	if ([self.arguments count])
	{
		[detailed appendString:@"\n\nArguments:\n"];
	}
	
	for (NSDictionary* argument in self.arguments)
	{
		NSString* argumentName = argument[@"short"];
		NSString* string = [NSString stringWithFormat:@"<%@>", argumentName];
		BOOL isOptional = [argument[@"optional"] boolValue];
		if (isOptional)
		{
			string = [NSString stringWithFormat:@"[%@]", string];
		}

		[description appendFormat:@"%@ ", string];

		[detailed appendFormat:@"\n\t%@ %@", [argumentName stringByPaddingToLength:paddingLength + 2 withString:@" " startingAtIndex:0], argument[@"description"]];
		NSString* extras = @"";
		if (isOptional)
		{
			extras = [extras stringByAppendingString:@"optional"];
		}

		NSString* defaultValue = argument[@"default"];
		if (defaultValue)
		{
			extras = [NSString stringWithFormat:@"%@, defaults to %@", extras, defaultValue];
		}

		if ([extras length] > 0)
		{
			[detailed appendFormat:@" (%@)", extras];
		}
	}

	NSDictionary* options = self.info[@"options"];
	NSArray* requiredOptions = options[@"required"];
	NSArray* optionalOptions = options[@"optional"];
	if (([requiredOptions count] + [optionalOptions count]) > 0)
	{
		[detailed appendString:@"\n\nOptions:\n"];
	}

	for (NSString* optionName in requiredOptions)
	{
		ECCommandLineOption* option = [engine optionWithName:optionName];
		[description appendFormat:@"--%@ ", optionName];
		[detailed appendFormat:@"\n\t--%@ %@", [optionName stringByPaddingToLength:paddingLength withString:@" " startingAtIndex:0], option.help];
	}

	for (NSString* optionName in optionalOptions)
	{
		ECCommandLineOption* option = [engine optionWithName:optionName];
		[description appendFormat:@"[ %@ | %@ ] ", option.longUsage, option.shortUsage];
		NSString* extras = @"optional";
		if (option.defaultValue)
		{
			extras = [NSString stringWithFormat:@"%@, defaults to %@", extras, option.defaultValue];
		}
		
		[detailed appendFormat:@"\n\t--%@ %@ (%@)", [optionName stringByPaddingToLength:paddingLength withString:@" " startingAtIndex:0], option.help, extras];
	}

	[description appendFormat:@"\n\n%@", self.help];

	NSString* result = [NSString stringWithFormat:@"%@ %@%@", self.name, description, detailed];

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
	// if we have a subcommand with the correct name, invoke that instead of the main command
	NSUInteger commandCount = [commands count];
	if (commandCount > 0) {
		NSString* potentialSubcommand = commands[0];
		ECCommandLineCommand* subcommand = self.subcommands[potentialSubcommand];
		if (subcommand) {
			NSMutableArray* subcommands = [NSMutableArray arrayWithArray:[commands subarrayWithRange:NSMakeRange(1, commandCount - 1)]];
			return [subcommand engine:engine processCommands:subcommands];
		}
	}

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
