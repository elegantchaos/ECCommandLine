// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineEngine.h"
#import "ECCommandLineCommand.h"

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

- (NSInteger)processArgumentCount:(NSUInteger)count arguments:(const char *[])arguments
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSDictionary* commands = bundle.infoDictionary[@"Commands"];
	[self registerCommands:commands];

	for (NSUInteger n = 0; n < count; ++n)
	{
		NSLog(@"%s", arguments[n]);
	}

	return 0;
}

@end