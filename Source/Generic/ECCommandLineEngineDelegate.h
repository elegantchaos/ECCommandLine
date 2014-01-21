//
//  ECCommandLineEngineDelegate.h
//  ECCommandLine
//
//  Created by Sam Deane on 26/09/2013.
//  Copyright (c) 2014 Sam Deane, Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECCommandLineEngine;

@protocol ECCommandLineEngineDelegate <NSObject>

- (void)engineDidFinishLaunching:(ECCommandLineEngine*)engine;

@optional

- (void)engine:(ECCommandLineEngine*)engine willProcessCommands:(NSArray*)commands;
- (void)engine:(ECCommandLineEngine*)engine didProcessCommands:(NSArray*)commands;

@end
