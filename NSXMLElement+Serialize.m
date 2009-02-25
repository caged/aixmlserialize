//
//  NSXMLElement+Serialize.m
//  NSXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "NSXMLElement+Serialize.h"


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

    
    //File
    if([type isEqualToString:@"file"])
    {
        return [NSDictionary dictionary];
    } 
    
    if([self kind] == NSXMLTextKind)
    {
        NSLog(@"%s =====================================IS TEXT KIND", _cmd);
    }
        
    for(node in nodes) 
    {
        NSMutableArray *group;
        NSString *elementName = [node name];
        group = [groups objectForKey:elementName];
        if(!group)
        {
            group = [NSMutableArray array];
            if([node kind] == NSXMLTextKind)
            {
                NSLog(@"TEXT NODE:%@", node);
                
            }
            NSLog(@"--------------------------------------------%@", node);
            if(elementName)
            [groups setObject:group forKey:elementName];
        } 
        
        [group addObject:node];
    }
    
    NSLog(@"%s GROUPS:%@", _cmd, groups);
    
    //Array
    if([type isEqualToString:@"array"])
    {
        NSLog(@"%s ITS AN ARRAy", _cmd);
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
    } 
    else 
    {
        NSLog(@"%s ITS A HASH", _cmd);
        out = [NSMutableDictionary dictionary];
        NSString *key;
        for(key in groups)
        {                           
            NSArray *obj = [groups objectForKey:key];
            //NSLog(@"%s obj:%i", _cmd, [obj count]);
            // There is only one object of this kind
            if([obj count] == 1)
            {                
                //NSLog(@"HASH IS EQUAL TO ONE");
                id subObj = [[obj objectAtIndex:0] toDictionary];
                if(subObj == nil)
                NSLog(@"-------------------------------------------------------SUB OBJ:%@", subObj);
                //[out addEntriesFromDictionary:]
                // if([key isEqualToString:@"committee"])
                //     NSLog(@"KEY:%@ OBJ:%@", key, [obj objectAtIndex:0]);
                //        
                // id finalObj = [obj objectAtIndex:0]; 
                // if([[finalObj children] count] > 0)
                // {
                //     id childObj = [finalObj childAtIndex:0];
                //     if([childObj kind] == NSXMLTextKind)
                //     {       
                //         NSString *contents = [childObj stringValue];
                //         [out setObject:contents forKey:key];
                //     } 
                //     else 
                //       {         
                //           NSMutableDictionary *subObj = [[finalObj toDictionary] valueForKey:key];
                //           [out setObject:subObj forKey:[finalObj name]];
                //       }
                // 
                // } 
                // else
                // { 
                //     NSString *contents = [finalObj stringValue];
                //     NSString *objName = [finalObj name];
                //     [out setObject:contents forKey:objName];
                // }
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
        
        //NSLog(@"NAME:%@", [self name]);
        
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
