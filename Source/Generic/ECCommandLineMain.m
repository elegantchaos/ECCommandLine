// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineMain.h"
#import "ECCommandLineEngine.h"

int ECCommandLineMain(int argc, const char * argv[])
{
	ECCommandLineEngine* cl = [[ECCommandLineEngine alloc] init];
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
