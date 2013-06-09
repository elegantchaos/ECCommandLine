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

@end
