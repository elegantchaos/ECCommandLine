//
//  ECCommandLineOption.m
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECCommandLineOption.h"

@interface ECCommandLineOption()

@property (strong, nonatomic, readwrite) NSString* name;
@property (strong, nonatomic) NSDictionary* info;

@end

@implementation ECCommandLineOption

+ (ECCommandLineOption*)optionWithName:(NSString*)name info:(NSDictionary*)info
{
	ECCommandLineOption* option = [[ECCommandLineOption alloc] initWithName:name info:info];

	return option;
}

- (id)initWithName:(NSString*)name info:(NSDictionary*)info
{
	if ((self = [super init]) != nil)
	{
		self.name = name;
		self.info = info;
		self.value = info[@"default"];
	}

	return self;
}

- (ECCommandLineOptionMode)mode
{
	ECCommandLineOptionMode result;
	NSString* value = self.info[@"mode"];
	if ([value isEqualToString:@"required"])
	{
		result = ECCommandLineOptionModeRequired;
	}

	else if ([value isEqualToString:@"optional"])
	{
		result = ECCommandLineOptionModeOptinal;
	}

	else
	{
		result = ECCommandLineOptionModeNone;
	}

	return result;
}

- (UniChar)shortOption
{
	NSString* shortOptionInfo = self.info[@"short"];
	UniChar result = ([shortOptionInfo length] > 0) ? [shortOptionInfo characterAtIndex:0] : 0;

	return result;
}

- (NSString*)help
{
	NSString* result = self.info[@"help"];

	return result;
}

- (NSString*)longUsage
{
	NSString* result = [NSString stringWithFormat:@"--%@", self.name];
	NSString* type = self.info[@"type"];
	if ([type isEqualToString:@"boolean"])
	{
		result = [NSString stringWithFormat:@"%@{=YES|NO} | --no-%@", result, self.name];
	}
	else if (type)
	{
		result = [NSString stringWithFormat:@"%@=<%@>", result, type];
	}

	return result;
}

- (NSString*)shortUsage
{
	NSString* result = [NSString stringWithFormat:@"-%lc", self.shortOption];
	NSString* type = self.info[@"type"];
	if ([type isEqualToString:@"boolean"])
	{
		result = [NSString stringWithFormat:@"%@ {<YES|NO>}", result];
	}
	else if (type)
	{
		result = [NSString stringWithFormat:@"%@ <%@>", result, type];
	}

	return result;
}

- (id)defaultValue
{
	id result = self.info[@"default"];
	NSString* type = self.info[@"type"];
	if ([type isEqualToString:@"boolean"])
	{
		result = [result boolValue] ? @"YES" : @"NO";
	}

	return result;
}

@end
