//
//  ECCommandLineOption.h
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ECCommandLineOptionMode)
{
	ECCommandLineOptionModeNone,
	ECCommandLineOptionModeRequired,
	ECCommandLineOptionModeOptinal,
};

@interface ECCommandLineOption : NSObject

@property (readonly, nonatomic) NSString* name;
@property (strong, nonatomic) id value;

+ (ECCommandLineOption*)optionWithName:(NSString*)name info:(NSDictionary*)info;

- (ECCommandLineOptionMode)mode;
- (UniChar)shortOption;
- (NSString*)help;
- (NSString*)longUsage;
- (NSString*)shortUsage;
- (id)defaultValue;

@end
