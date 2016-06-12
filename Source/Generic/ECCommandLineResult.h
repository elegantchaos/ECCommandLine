//
//  ECCommandLineResult.h
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ECCommandLineDomain;

typedef NS_ENUM(NSInteger, ECCommandLineResult)
{
	ECCommandLineResultOKButTerminate = -2,
	ECCommandLineResultStayRunning = -1,
	ECCommandLineResultOK = 0,
	ECCommandLineResultUnknownCommand,
	ECCommandLineResultMissingCommandClass,
	ECCommandLineResultNotImplemented,
	ECCommandLineResultMissingArguments,
	ECCommandLineResultImplementationReturnedError,
	ECCommandLineResultMissingBundle,
};
