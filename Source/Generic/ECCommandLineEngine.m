// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineEngine.h"
#import "ECCommandLineCommand.h"
#import "ECCommandLineOption.h"

#import <getopt.h>

@interface ECCommandLineEngine()

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableDictionary* commands;
@property (strong, nonatomic) NSMutableDictionary* options;
@property (strong, nonatomic) NSMutableDictionary* optionsByShortName;
@property (strong, nonatomic) ECCommandLineOption* helpOption;
@property (strong, nonatomic) ECCommandLineOption* versionOption;

@end

@implementation ECCommandLineEngine

- (id)init
{
	if ((self = [super init]) != nil)
	{
		self.commands = [NSMutableDictionary dictionary];
		self.options = [NSMutableDictionary dictionary];
		self.optionsByShortName = [NSMutableDictionary dictionary];
	}

	return self;
}

ECDefineDebugChannel(CommandLineEngineChannel);

#pragma mark - Commands

- (void)registerCommandNamed:(NSString*)name withInfo:(NSDictionary*)info
{
	ECDebug(CommandLineEngineChannel, @"registered command %@", name);

	ECCommandLineCommand* command = [ECCommandLineCommand commandWithName:name info:info];
	self.commands[name] = command;
}

- (void)registerCommands:(NSDictionary*)commands
{
	[commands enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
		[self registerCommandNamed:name withInfo:info];
	}];
}

#pragma mark - Options

- (void)registerOptionNamed:(NSString*)name withInfo:(NSDictionary*)info
{
	ECDebug(CommandLineEngineChannel, @"registered option %@", name);

	ECCommandLineOption* option = [ECCommandLineOption optionWithName:name info:info];
	self.options[name] = option;
	self.optionsByShortName[[NSString stringWithFormat:@"%c", option.shortOption]] = option;
}

- (void)registerOptions:(NSDictionary*)options
{
	[options enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
		[self registerOptionNamed:name withInfo:info];
	}];
}

- (void)logArguments:(int)argc argv:(const char **)argv
{
	for (int n = 0; n < argc; ++n)
	{
		NSLog(@"%s", argv[n]);
	}
}

- (struct option*)setupOptionsArrayWithShortOptions:(const char**)shortOptions
{
	NSUInteger optionsCount = [self.options count];
	struct option* optionsArray = calloc(optionsCount + 1, sizeof(struct option));
	__block struct option* optionPtr = optionsArray;
	NSMutableString* shortBuffer = [[NSMutableString alloc] init];
	[self.options enumerateKeysAndObjectsUsingBlock:^(NSString* optionName, ECCommandLineOption* option, BOOL *stop) {
		optionPtr->name = strdup([optionName UTF8String]);
		optionPtr->has_arg = option.mode;
		optionPtr->flag = NULL;
		optionPtr->val = option.shortOption;
		[shortBuffer appendFormat:@"%c", option.shortOption];
		optionPtr++;
	}];

	*shortOptions = strdup([shortBuffer UTF8String]);

	return optionsArray;
}

- (void)cleanupOptionsArray:(struct option*)optionsArray withShortOptions:(const char*)shortOptions
{
	NSUInteger optionsCount = [self.options count];
	for (NSUInteger n = 0; n < optionsCount; ++n)
	{
		free((char*)(optionsArray[n].name));
	}
	free(optionsArray);
	free((void*)shortOptions);
}

- (void)processOption:(ECCommandLineOption*)option value:(id)value
{
	if (!value)
		value = @(YES);

	ECDebug(CommandLineEngineChannel, @"option %@ = %@", option.name, value);
	option.value = value;
}

- (void)setupFromBundle
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSDictionary* commands = bundle.infoDictionary[@"Commands"];
	NSDictionary* options = bundle.infoDictionary[@"Options"];
	[self registerCommands:commands];
	[self registerOptions:options];

	// TODO: maybe load these from a plist?
	[self registerOptions:
	 @{
	 @"version": @{@"short" : @"v", @"help" : @"show version number"},
	 @"help": @{@"short" : @"h", @"help" : @"show command help"}
	 }
	 ];

	self.versionOption = self.options[@"version"];
	self.helpOption = self.options[@"help"];
}

- (ECCommandLineResult)processArguments:(int)argc argv:(const char **)argv
{
	self.name = [[[NSString alloc] initWithUTF8String:argv[0]] lastPathComponent];

	//	[self logArguments:argc argv:argv];
	[self setupFromBundle];

	const char* shortOptions = nil;
	struct option* optionsArray = [self setupOptionsArrayWithShortOptions:&shortOptions];
	int optionIndex = -1;
	int shortOption;

	NSUInteger processedOptions = 0;
	while ((shortOption = getopt_long(argc, (char *const *)argv, shortOptions, optionsArray, &optionIndex)) != -1)
	{
		++processedOptions;
		switch (shortOption)
		{
			case '?':
				NSLog(@"unknown option %s", optarg);
				break;

			case ':':
				NSLog(@"missing value %s", optarg);
				break;

			default:
			{
				ECCommandLineOption* option = self.optionsByShortName[[NSString stringWithFormat:@"%c", (char)shortOption]];
				NSString* optionValue = optarg ? [[NSString alloc] initWithCString:optarg encoding:NSUTF8StringEncoding] : nil;
				[self processOption:option value:optionValue];
			}
		}
	}

	[self cleanupOptionsArray:optionsArray withShortOptions:shortOptions];

	ECCommandLineResult result;
	if ((processedOptions + 1) < (NSUInteger)argc)
	{
		NSMutableArray* remainingArguments = [NSMutableArray arrayWithCapacity:argc - processedOptions];
		for (NSUInteger n = processedOptions + 1; n < (NSUInteger)argc; ++n)
		{
			[remainingArguments addObject:[[NSString alloc] initWithCString:argv[n] encoding:NSUTF8StringEncoding]];
		}

		result = [self processCommands:remainingArguments];
	}
	else
	{
		result = [self processNoCommands];
	}

	if (result == ECCommandLineResultUnknownCommand)
	{
		[self showUsage];
	}

	return result;
}

- (void)showUsage
{
	NSString* usage = [NSString stringWithFormat:@"Usage: %@ ", self.name];
	NSString* padding = [@"" stringByPaddingToLength:[usage length] withString:@" " startingAtIndex:0];
	NSMutableString* string = [NSMutableString stringWithFormat:@"%@", usage];
	[self.options enumerateKeysAndObjectsUsingBlock:^(NSString* name, ECCommandLineOption* option, BOOL *stop) {
		NSString* optionString = [NSString stringWithFormat:@" [ --%@ ]", option.name];
		if ([string length] + [optionString length] > 70)
		{
			NSLog(@"%@", string);
			[string setString:padding];
		}

		[string appendString:optionString];
	}];
	NSLog(@"%@", string);

	NSLog(@"\n\nCommands:");
	[self.commands enumerateKeysAndObjectsUsingBlock:^(NSString* name, ECCommandLineCommand* command, BOOL *stop) {
		NSLog(@"\t%@ %@", name, command.help);
	}];

	NSLog(@"\n\nSee ‘%@ help <command>’ for more information on a specific command.", self.name);
}

- (void)showHelp
{
	NSLog(@"help goes here");
}

- (void)showVersion
{
	NSLog(@"version goes here");
}

- (ECCommandLineResult)processCommands:(NSMutableArray*)commands
{
	NSString* commandName = [commands objectAtIndex:0];
	[commands removeObjectAtIndex:0];

	ECCommandLineResult result;
	if ([commandName isEqualToString:@"--"])
	{
		// skip to next command
		result = [self processCommands:commands];
	}
	else
	{
		ECCommandLineCommand* command = self.commands[commandName];
		if (command)
		{
			result = [command processCommands:commands];
		}
		else
		{
			result = [self processUnknownCommand:commandName];
		}
	}

	return result;
}

- (ECCommandLineResult)processNoCommands
{
	ECCommandLineResult result = ECCommandLineResultOKButTerminate;
	if ([self.versionOption.value boolValue])
	{
		[self showVersion];
	}
	else if ([self.helpOption.value boolValue])
	{
		[self showHelp];
	}
	else
	{
		result = ECCommandLineResultUnknownCommand;
	}
	
	return result;
}

- (ECCommandLineResult)processUnknownCommand:(NSString*)command
{
	NSLog(@"unknown command %@", command);
	return ECCommandLineResultUnknownCommand;
}

@end