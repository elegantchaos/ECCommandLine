//
//  ECCommandLineCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineCommand.h"

@interface ECCommandLineCommand()

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSDictionary* info;

@end

@implementation ECCommandLineCommand

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info
{
	ECCommandLineCommand* command = [[ECCommandLineCommand alloc] initWithName:name info:info];

	return command;
}

- (id)initWithName:(NSString*)name info:(NSDictionary*)info
{
	if ((self = [super init]) != nil)
	{
		self.name = name;
		self.info = info;
	}

	return self;
}

@end
