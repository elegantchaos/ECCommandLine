// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 09/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@import ECUnitTests;

@interface ExampleToolTests : ECTestCase

@end


@implementation ExampleToolTests

- (NSString*)runToolWithArguments:(NSArray*)arguments {
	NSString* path = [[NSBundle bundleForClass:[self class]].bundlePath stringByDeletingLastPathComponent];

	int status;
	NSData* errorData = nil;
	NSData *data = [self runCommand:[path stringByAppendingPathComponent:@"ECCommandLineExample"] arguments:arguments status:&status error:&errorData];

	NSString* output = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
	NSString* error = [[NSString alloc] initWithData: errorData encoding:NSUTF8StringEncoding];
	output = [output stringByAppendingString:error];

	return output;
}


- (void)testHelp {
	NSURL* expectedURL = [self URLForTestResource:@"Help" withExtension:@"txt"];
	NSString* output = [self runToolWithArguments:nil];
	[self assertString:output matchesContentsOfURL:expectedURL mode:ECTestComparisonDiff];
}

- (void)testExample {
	NSString* output = [self runToolWithArguments:@[@"example", @"argument"]];
	[self assertString:output matchesString:@"This is an example command. It's not very useful. The argument was “argument”. The parameter was “waffle”" mode:ECTestComparisonDiff];
}

- (void)testExampleNoArgument {
	NSString* output = [self runToolWithArguments:@[@"example"]];
	[self assertString:output matchesString:@"We were expecting an argument." mode:ECTestComparisonDiff];
}

- (void)testExampleWithOption {
	NSString* output = [self runToolWithArguments:@[@"example", @"argument", @"--blah=doodah"]];
	[self assertString:output matchesString:@"This is an example command. It's not very useful. The argument was “argument”. The parameter was “doodah”" mode:ECTestComparisonDiff];
}

- (void)testUnknown {
	NSString* output = [self runToolWithArguments:@[@"zoinks"]];
	NSString* line1 = [output componentsSeparatedByString:@"\n"][0];
	[self assertString:line1 matchesString:@"Unknown command ‘zoinks’" mode:ECTestComparisonDiff];
}

@end
