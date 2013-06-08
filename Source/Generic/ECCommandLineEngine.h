// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

ECDeclareDebugChannel(CommandLineEngineChannel);

@interface ECCommandLineEngine : NSObject

- (NSInteger)processArguments:(int)argc argv:(const char **)argv;

@end