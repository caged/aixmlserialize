//
//  NSXMLElement+Serialize.m
//  NSXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "NSXMLElement+Serialize.h"
#import <libxml/hash.h>


@implementation NSXMLElement (Serialize)
- (NSDictionary *)attributesAsDictionary
{
	NSArray *attributes = [self attributes];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[attributes count]];
	
	uint i;
	for(i = 0; i < [attributes count]; i++)
	{
		NSXMLNode *node = [attributes objectAtIndex:i];
		
		[result setObject:[node stringValue] forKey:[node name]];
	}
	return result;
}

- (NSMutableDictionary *)toDictionary
{
    id out;
    NSMutableDictionary *groups = [NSMutableDictionary dictionary];
    NSXMLNode *node;
    NSArray *nodes = [self children];
   
    // Create distinct arrays for items with the same name
    //NSArray *keys = [self valueForKeyPath:@"children.@distinctUnionOfObjects.name"];
    NSString *type = [[self attributesAsDictionary] valueForKey:@"type"];
    
    //NSLog(@"%s name:%@", _cmd, [self name]);
    //NSLog(@"%s type:%@", _cmd, type);
    
    for(node in nodes) 
    {
        NSMutableArray *group;
        NSString *elementName = [node name];
        group = [groups objectForKey:elementName];
        if(!group)
        {
            group = [NSMutableArray array];
            [groups setObject:group forKey:elementName];
        }
        
        [group addObject:node];
    }
    
    if([self kind] == NSXMLTextKind)
    {
        NSLog(@"%s IS TEXT KIND:%@", _cmd, [node name]);
    }
    
    // Array
    if([type isEqualToString:@"array"])
    {
        out = [NSMutableArray array];
        NSString *key;
        for(key in groups)
        {
            id obj = [groups objectForKey:key];
            if([obj count] == 1)
            {
                NSLog(@"%s COUNT IS 1", _cmd);
            } 
            else
            {
                for(id el in obj)
                {
                    NSMutableDictionary *dict = [el toDictionary];
                    id newObj = [dict valueForKey:key];
                    [out addObject:newObj];
                }
            }
        }
    
    // NSDictionary    
    } else {
        out = [NSMutableDictionary dictionary];
        NSString *key;
        for(key in groups)
        {
            id obj = [groups objectForKey:key];            
            if([obj count] == 1)
            {
                id finalObj = [obj objectAtIndex:0]; 
                if([[finalObj children] count] > 0)
                {                    
                    if([[finalObj childAtIndex:0] kind] == NSXMLTextKind)
                    {                        
                        id childObj = [finalObj childAtIndex:0];
                        NSString *contents = [childObj stringValue];
                        [out setObject:contents forKey:key];
                    } 
                    else 
                    {                        
                        NSMutableDictionary *subObj = [[finalObj toDictionary] valueForKey:key];
                        [out setObject:subObj forKey:[finalObj name]];
                    }

                } 
                else
                {   
                    //This is where nodes with no text value fall                  
                    //NSString *contents = [finalObj stringValue];
                    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
                    NSDictionary *attrs = [finalObj attributesAsDictionary];
                    if([attrs count] > 0)
                        [attrDict addEntriesFromDictionary:attrs];
                        
                    NSString *objName = [finalObj name];
                    [out setObject:attrDict forKey:objName];
                }
            } 
            else
            {
                NSMutableArray *subOut = [NSMutableArray array];
                for(id el in obj)
                {
                    NSMutableDictionary *dict = [el toDictionary];
                    NSMutableDictionary *aDict = [dict valueForKey:key];
                    [subOut addObject:aDict];
                    NSMutableDictionary *subDict = [NSMutableDictionary dictionaryWithObject:subOut forKey:key];
                    [out addEntriesFromDictionary:subDict];
                }
            }
        }
        
        NSDictionary *attrs = [self attributesAsDictionary];
        if([attrs count] > 0)
            [out addEntriesFromDictionary:attrs];
    }
    
    if(type && (out == nil))
    {
        NSLog(@"%s out is nil", _cmd);
        return [NSMutableDictionary dictionary];
    }
    
    return [NSMutableDictionary dictionaryWithObject:out forKey:[self name]];
}
@end
