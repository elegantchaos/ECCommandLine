//
//  ECCommandLineCommand.h
//  ECCommandLine
//
//  Created by Sam Deane on 08/06/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCommandLineCommand : NSObject

+ (ECCommandLineCommand*)commandWithName:(NSString*)name info:(NSDictionary*)info;

@property (strong, nonatomic, readonly) NSString* name;

@end
