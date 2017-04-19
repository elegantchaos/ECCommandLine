// --------------------------------------------------------------------------
//
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "NSDictionary+ECCommandLine.h"


@implementation NSDictionary(ECCommandLine)

// --------------------------------------------------------------------------
//! If a given key is in the dictionary, place its value into a bool variable.
// --------------------------------------------------------------------------

- (id) valueForKey: (NSString*) key intoBool: (BOOL*) valueOut
{
	id value = [self valueForKey: key];
	if (value)
	{
		*valueOut = [value boolValue];
	}
	
	return value;
}

// --------------------------------------------------------------------------
//! If a given key is in the dictionary, place its value into a double variable.
// --------------------------------------------------------------------------

- (id) valueForKey: (NSString*) key intoDouble: (double*) valueOut
{
	id value = [self valueForKey: key];
	if (value)
	{
		*valueOut = [value doubleValue];
	}
	
	return value;
}

// --------------------------------------------------------------------------
//! Return a dictionary identical to this except without a given key.
// --------------------------------------------------------------------------

- (NSDictionary*)dictionaryWithoutKey:(NSString*)key
{
    id object = self[key];
    if (object)
    {
        NSMutableDictionary* copy = [self mutableCopy];
        [copy removeObjectForKey:key];
        return copy;
    }
    else
    {
        return self;
    }
}

// --------------------------------------------------------------------------
//! Return a point from a given dictionary key.
//! The key is assumed to contain an array with two double values in it.
// --------------------------------------------------------------------------

- (CGPoint)pointForKey:(NSString*)key
{
    NSArray* values = self[key];
    CGPoint result = CGPointMake((CGFloat)[values[0] doubleValue], (CGFloat)[values[1] doubleValue]);

    return result;
}

// --------------------------------------------------------------------------
//! Return a size from a given dictionary key.
//! The key is assumed to contain an array with two double values in it.
// --------------------------------------------------------------------------

- (CGSize)sizeForKey:(NSString*)key
{
    NSArray* values = self[key];
    CGSize result = CGSizeMake((CGFloat)[values[0] doubleValue], (CGFloat)[values[1] doubleValue]);
    
    return result;
}

// --------------------------------------------------------------------------
//! Return a rect from a given dictionary key.
//! The key is assumed to contain an array with two double values in it.
// --------------------------------------------------------------------------

- (CGRect)rectForKey:(NSString*)key
{
    NSArray* values = self[key];
    CGRect result = CGRectMake((CGFloat)[values[0] doubleValue], (CGFloat)[values[1] doubleValue], (CGFloat)[values[2] doubleValue], (CGFloat)[values[3] doubleValue]);
    
    return result;
}

@end


@implementation NSMutableDictionary(ECCommandLine)

// --------------------------------------------------------------------------
//! Store a point in a dictionary under a given key.
//! The point is stored as an array with two double values in it.
// --------------------------------------------------------------------------

- (void)setPoint:(CGPoint)point forKey:(NSString*)key
{
    NSArray* values = @[@(point.x), @(point.y)];
    self[key] = values;
}

// --------------------------------------------------------------------------
//! Store a point in a dictionary under a given key.
//! The point is stored as an array with two double values in it.
// --------------------------------------------------------------------------

- (void)setSize:(CGSize)size forKey:(NSString*)key
{
    NSArray* values = @[@(size.width), @(size.height)];
    self[key] = values;
}

// --------------------------------------------------------------------------
//! Store a point in a dictionary under a given key.
//! The point is stored as an array with two double values in it.
// --------------------------------------------------------------------------

- (void)setRect:(CGRect)rect forKey:(NSString*)key
{
    NSArray* values = @[@(rect.origin.x), @(rect.origin.y), @(rect.size.width), @(rect.size.height)];
    self[key] = values;
}

// --------------------------------------------------------------------------
//! Merge the first level of keys in this dictionary with those in another dictionary.
// --------------------------------------------------------------------------

- (void)mergeEntriesFromDictionary:(NSDictionary*)dictionary
{
    for (NSString* key in dictionary)
    {
        id existingItem = self[key];
        id newItem = dictionary[key];
        if (existingItem && newItem)
        {
            if ([existingItem isKindOfClass:[NSDictionary class]] && [newItem isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:existingItem];
                [merged addEntriesFromDictionary:newItem];
                newItem = merged;
            }
        }
        
        if (newItem)
        {
            self[key] = newItem;
        }
    }

}
@end
