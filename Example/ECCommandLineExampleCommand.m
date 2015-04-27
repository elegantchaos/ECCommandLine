//
//  ECCommandLineExampleCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 09/06/2013.
//  Copyright (c) 2014 Sam Deane, Elegant Chaos. All rights reserved.
//

#import "ECCommandLineExampleCommand.h"

@implementation ECCommandLineExampleCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	NSString* blah = [engine stringOptionForKey:@"blah"];
	[engine outputFormat:@"This is an example command. It's not very useful. The blah parameter was “%@”", blah];

	return ECCommandLineResultOK;
}

@end
