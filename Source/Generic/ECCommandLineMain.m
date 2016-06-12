// --------------------------------------------------------------------------
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineMain.h"
#import "ECCommandLineEngine.h"
#import "ECCommandLineEngineDelegate.h"

#import "crt_externs.h"

int ECCommandLineMainNoArgs(void)
{
	int* argc = _NSGetArgc();
	char *** argv = _NSGetArgv();
	int result = 0;
	if (argc && argv)
		result = ECCommandLineMain(*argc, (const char**)*argv);
	
	return result;
}


int ECCommandLineMain(int argc, const char * argv[])
{
	NSBundle* bundle = [NSBundle mainBundle];
	id<ECCommandLineEngineDelegate> delegate = nil;
	NSString* delegateClass = bundle.infoDictionary[@"ECCommandLineEngineDelegate"];
	if (delegateClass)
		delegate = [NSClassFromString(delegateClass) new];

	ECCommandLineEngine* cl = [[ECCommandLineEngine alloc] initWithDelegate:delegate];

	dispatch_async(dispatch_get_main_queue(), ^{
		ECCommandLineResult processResult = [cl processArguments:argc argv:argv];
		if (processResult != ECCommandLineResultOK)
		{
			if (processResult == ECCommandLineResultOKButTerminate)
				processResult = ECCommandLineResultOK;

			exit(processResult);
		}
	});

	CFRunLoopRun();

	return 0;
}
