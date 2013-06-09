//
//  ECCommandLineHelpCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 09/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineHelpCommand.h"

@implementation ECCommandLineHelpCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
	[engine showHelp];
	return ECCommandLineResultOKButTerminate;
}

@end
