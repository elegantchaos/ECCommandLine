//
//  ECCommandLineHelpCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 09/06/2013.
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//

#import "ECCommandLineHelpCommand.h"

@implementation ECCommandLineHelpCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	NSUInteger count = [arguments count];
	if (count == 0)
	{
		[engine showUsage];
	}
	else
	{
		NSString* commandName = arguments[0];
		ECCommandLineCommand* command = [engine commandWithName:commandName];
		if (command)
		{
			[arguments removeObjectAtIndex:0];
			ECCommandLineCommand* resolved = [command resolveCommandPath:arguments];
			[engine outputFormat:@"Usage: %@\n", [resolved usageAs:commandName parentName:nil engine:engine]];
		}
	}

	return ECCommandLineResultOKButTerminate;
}

@end
