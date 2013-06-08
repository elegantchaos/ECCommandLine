//
//  ECCommandLineCommand.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineCommand.h"

@interface ECCommandLineCommand()

@property (strong, nonatomic, readwrite) NSString* name;
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

- (ECCommandLineArgumentMode)argumentModeForValue:(NSString*)value
{
	ECCommandLineArgumentMode result;
	if ([value isEqualToString:@"required"])
	{
		result = ECCommandLineArgumentModeRequired;
	}

	else if ([value isEqualToString:@"optional"])
	{
		result = ECCommandLineArgumentModeOptinal;
	}

	else
	{
		result = ECCommandLineArgumentModeNone;
	}

	return result;
}

- (void)enumerateArguments:(ArgumentBlock)block
{
	NSDictionary* arguments = self.info[@"arguments"];
	[arguments enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
		NSString* shortOptionInfo = info[@"short"];
		UniChar shortOption = ([shortOptionInfo length] > 0) ? [shortOptionInfo characterAtIndex:0] : 0;
		ECCommandLineArgumentMode mode = [self argumentModeForValue:info[@"mode"]];

		block(name, mode, shortOption, info);
	}];
}

@end
