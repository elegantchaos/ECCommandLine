//
//  ECCommandLineExampleCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 09/06/2013.
//  Copyright (c) 2014 Sam Deane, Elegant Chaos. All rights reserved.
//

#import "ECCommandLineExampleCommand.h"
@import ECCommandLine.ECCommandLineEngine;

@implementation ECCommandLineExampleCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	if ([arguments count] == 1)
	{
		NSString* blah = [engine stringOptionForKey:@"blah"];
		[engine outputFormat:@"This is an example command. It's not very useful. The argument was “%@”. The parameter was “%@”", arguments[0], blah];
	}
	else
	{
		[engine outputErrorWithDomain:ECCommandLineDomain code:ECCommandLineResultMissingArguments info:@{} format:@"We were expecting an argument."];
	}
	return ECCommandLineResultOK;
}

@end
