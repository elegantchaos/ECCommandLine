// --------------------------------------------------------------------------
//  Copyright (c) 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineMain.h"
#import "ECCommandLineEngine.h"
#import "ECCommandLineEngineDelegate.h"

int ECCommandLineMain(int argc, const char * argv[])
{
	NSBundle* bundle = [NSBundle mainBundle];
	id<ECCommandLineEngineDelegate> delegate = nil;
	NSString* delegateClass = bundle.infoDictionary[@"ECCommandLineEngineDelegate"];
	if (delegateClass)
		delegate = [NSClassFromString(delegateClass) new];

	ECCommandLineEngine* cl = [[ECCommandLineEngine alloc] initWithDelegate:delegate];
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		ECCommandLineResult processResult = [cl processArguments:argc argv:argv];
		if (processResult != ECCommandLineResultOK)
		{
			if (processResult == ECCommandLineResultOKButTerminate)
				processResult = ECCommandLineResultOK;

			exit(processResult);
		}
	}];

	int result = NSApplicationMain(argc, argv);

	return result;
}
