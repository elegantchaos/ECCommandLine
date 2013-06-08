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

@property (strong, nonatomic) NSMutableDictionary* commands;
@property (strong, nonatomic) NSMutableDictionary* options;

@end

@implementation ECCommandLineEngine

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
	self.commands = [NSMutableDictionary dictionary];

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
}

- (void)registerOptions:(NSDictionary*)options
{
	self.options = [NSMutableDictionary dictionary];

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
- (NSInteger)processArguments:(int)argc argv:(const char **)argv
{
	[self logArguments:argc argv:argv];
	
	NSBundle* bundle = [NSBundle mainBundle];
	NSDictionary* commands = bundle.infoDictionary[@"Commands"];
	NSDictionary* options = bundle.infoDictionary[@"Options"];
	[self registerCommands:commands];
	[self registerOptions:options];

	NSUInteger optionsCount = [self.options count];
	struct option* optionsArray = calloc(optionsCount, sizeof(struct option));
	__block struct option* optionPtr = optionsArray;
	NSMutableString* shortOptions = [[NSMutableString alloc] init];
	[self.options enumerateKeysAndObjectsUsingBlock:^(NSString* optionName, ECCommandLineOption* option, BOOL *stop) {
		optionPtr->name = strdup([optionName UTF8String]);
		optionPtr->has_arg = option.mode;
		optionPtr->flag = NULL;
		optionPtr->val = option.shortOption;
		[shortOptions appendFormat:@"%c", option.shortOption];
		optionPtr++;
	}];

	int optionIndex = -1;
	int shortOption;

	char* shortOptionsC = strdup([shortOptions UTF8String]);
	while ((shortOption = getopt_long(argc, (char *const *)argv, shortOptionsC, optionsArray, &optionIndex)) != -1)
	{
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
				NSString* optionName = [NSString stringWithUTF8String:optionsArray[optionIndex].name];
				NSLog(@"option name %@ value %s", optionName, optarg);
			}
		}
	}

	for (NSUInteger n = 0; n < optionsCount; ++n)
	{
		free((char*)(optionsArray[n].name));
	}
	free(optionsArray);
	free(shortOptionsC);

	return 0;
}

@end