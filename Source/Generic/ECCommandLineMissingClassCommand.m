//
//  ECCommandLineMissingClassCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineMissingClassCommand.h"

@implementation ECCommandLineMissingClassCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	NSLog(@"Command class missing for %@ (%@)", self.name, [self class]);

	return ECCommandLineResultMissingCommandClass;
}

- (NSString*)ourSummaryAs:(NSString*)name
{
	return @"";
}

- (NSString*)ourUsageAs:(NSString*)name engine:(ECCommandLineEngine*)engine
{
	NSString* further = [NSString stringWithFormat:@"Type: %@ help %@ <subcommand> for more detail on a subcommand.", engine.name, name];
	NSString* result = [NSString stringWithFormat:@"%@ %@ <subcommand>\n\nSubcommands:\n%@\n\n%@", engine.name, name, [self subcommandSummaryAs:name], further];

	 return result;
}

@end
