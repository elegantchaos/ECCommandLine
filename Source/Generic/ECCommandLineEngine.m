// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineEngine.h"
#import "ECCommandLineCommand.h"

#import <getopt.h>

@interface ECCommandLineEngine()

@property (strong, nonatomic) NSMutableDictionary* commands;

@end

@implementation ECCommandLineEngine

ECDefineDebugChannel(CommandLineEngineChannel);

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
	[self registerCommands:commands];

	NSUInteger optionsCount = [self.commands count];
	struct option* options = calloc(optionsCount, sizeof(struct option));
	__block struct option* option = options;
	NSMutableString* shortOptions = [[NSMutableString alloc] init];
	[self.commands enumerateKeysAndObjectsUsingBlock:^(NSString* commandName, ECCommandLineCommand* command, BOOL *stop) {
		[command enumerateArguments:^(NSString* argumentName, ECCommandLineArgumentMode mode, UniChar shortOption, NSDictionary *info) {
			option->name = strdup([argumentName UTF8String]);
			option->has_arg = mode;
			option->flag = NULL;
			option->val = shortOption;
			[shortOptions appendFormat:@"%c", shortOption];
			option++;
		}];
	}];

	int optionIndex = -1;
	int opt;

	char* shortOptionsC = strdup([shortOptions UTF8String]);
	while ((opt = getopt_long(argc, (char *const *)argv, shortOptionsC, options, &optionIndex)) != -1)
	{
		NSString* optionName = [NSString stringWithUTF8String:options[optionIndex].name];
		NSLog(@"option name %@", optionName);
	}

	for (NSUInteger n = 0; n < optionsCount; ++n)
	{
		free((char*)(options[n].name));
	}
	free(options);
	free(shortOptionsC);

	return 0;
}

@end