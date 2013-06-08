// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineEngine.h"

@interface ECCommandLineEngine()

@end

@implementation ECCommandLineEngine

- (NSInteger)processArgumentCount:(NSUInteger)count arguments:(const char *[])arguments
{
	for (NSUInteger n = 0; n < count; ++n)
	{
		NSLog(@"%s", arguments[n]);
	}

	return 0;
}

@end