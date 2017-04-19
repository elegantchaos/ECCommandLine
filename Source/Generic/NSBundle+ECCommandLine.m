// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "NSBundle+ECCommandLine.h"


@implementation NSBundle(ECCommandLine)


// --------------------------------------------------------------------------
//! Return the bundle name of the bundle.
// --------------------------------------------------------------------------

- (NSString*) bundleName
{
    NSDictionary* info = [self infoDictionary];
    NSString* result = info[@"CFBundleName"];
    
    return result;
}

// --------------------------------------------------------------------------
//! Return the user readable bundle version (e.g. 1.2).
// --------------------------------------------------------------------------

- (NSString*) bundleVersion
{
    NSDictionary* info = [self infoDictionary];
    NSString* result = info[@"CFBundleShortVersionString"];
    
    return result;
}

// --------------------------------------------------------------------------
//! Return the real bundle version (typically a build number, like 1535).
// --------------------------------------------------------------------------

- (NSString*) bundleBuild
{
    NSDictionary* info = [self infoDictionary];
    NSString* result = info[@"CFBundleVersion"];
    
    return result;
}

// --------------------------------------------------------------------------
//! Return a string showing the bundle version, with the build number,
//! eg "Version 1.0b2 (343)"
// --------------------------------------------------------------------------

- (NSString*) bundleFullVersion
{
    NSDictionary* info = [self infoDictionary];
    NSString *mainString = [info valueForKey:@"CFBundleShortVersionString"];
    NSString *subString = [info valueForKey:@"CFBundleVersion"];
    NSString* result = [NSString stringWithFormat:@"Version %@ (%@)", mainString, subString];
    
    return result;
}

// --------------------------------------------------------------------------
//! Return the user readable copyright notice for the bundle.
// --------------------------------------------------------------------------

- (NSString*) bundleCopyright
{
    NSDictionary* info = [self infoDictionary];
    NSString* result = info[@"NSHumanReadableCopyright"];
    
    return result;
}

@end
