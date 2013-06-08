//
//  ECCommandLineCommand.h
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ECCommandLineArgumentMode)
{
	ECCommandLineArgumentModeNone,
	ECCommandLineArgumentModeRequired,
	ECCommandLineArgumentModeOptinal,
};

typedef void(^ArgumentBlock)(NSString* name, ECCommandLineArgumentMode mode, UniChar shortOption, NSDictionary* info);

@interface ECCommandLineCommand : NSObject

@property (readonly, nonatomic) NSString* name;

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info;

- (void)enumerateArguments:(ArgumentBlock)block;

@end
