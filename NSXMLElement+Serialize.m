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
static NSString *contentItem;
+ (void)initialize
{
    if(!contentItem)
        contentItem = @"content";
}

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
    id out, rawObj;
    NSXMLNode *node;
    NSArray *nodes = [self children];
    NSString *elName = [self name], *key;
    NSDictionary *attrs = [self attributesAsDictionary];
    NSString *type = [attrs valueForKey:@"type"];
    NSMutableDictionary *groups = [NSMutableDictionary dictionary], *collectionDict;
    NSMutableArray *objs;
    
    if([self kind] == NSXMLTextKind)
    {
        return [NSMutableDictionary dictionaryWithObject:[self stringValue] forKey:elName];
    }
    
    for(node in nodes)
    {
        if([node kind] == NSXMLElementKind)
        {
            NSString *childName = [node name];
            NSMutableArray *group = [groups objectForKey:childName];
            if(!group)
            {
                group = [NSMutableArray array];
                [groups setObject:group forKey:childName];
            }

            [group addObject:node];
        } 
        // It's really slow when we call back into toDictionary so we can handle text nodes
        // so comment this out for now.
        // We're on a text node so the parent node will be this nodes name.
        // else if([node kind] == NSXMLTextKind) 
        // {
        //     return [NSMutableDictionary dictionaryWithObject:[node stringValue] forKey:[[node parent] name]];
        // }
    }
    
    // Array
    if([type isEqualToString:@"array"])
    {
        out = [NSMutableArray array];
        for(key in groups)
        {
            NSMutableDictionary *dictRep;
            objs = [groups objectForKey:key];  
            for(rawObj in objs)
            {
                dictRep = [rawObj toDictionary];
                [out addObject:[dictRep valueForKey:key]];
            }
        }
        
        // ?need to flatten out here?
    }
    // Dictionary
    else
    {
        out = [NSMutableDictionary dictionary];
        for(key in groups)
        {
            NSMutableDictionary *dictRep;
            objs = [groups objectForKey:key];
            if([objs count] == 1)
            {                
                // We get a 2x speed increase if we check the rawObject's child
                // node to see if it's a text node.  If it is, we go ahead and 
                // add it to the output here instead of running it back through 
                // toDictionary.
                rawObj = [objs objectAtIndex:0];
                node = [rawObj childAtIndex:0];
                dictRep = [NSMutableDictionary dictionary];
                if([node kind] == NSXMLTextKind)
                {
                    NSDictionary *nodeAttrs = [rawObj attributesAsDictionary]; 
                    NSString *contents = [node stringValue];
                    id nodeObj;
                    
                    // If this node has attributes and content text we need to 
                    // create a dictionary for it and use the static contentItem 
                    // value as a place to store the stringValue.
                    if(nodeAttrs && contents)
                    {
                        nodeObj = [NSMutableDictionary dictionaryWithObject:contents forKey:contentItem];
                        [nodeObj addEntriesFromDictionary:nodeAttrs];
                    }
                    // Else this node only has a string value or is empty so we set 
                    // it's value to a string.
                    else
                    {
                        nodeObj = contents;
                    }
                    
                    [out setObject:nodeObj forKey:key];
                }
                else
                {
                    //NSDictionary *nodeAttrs = [(NSXMLElement *)node attributesAsDictionary];
                    dictRep = [[objs objectAtIndex:0] toDictionary];
                    [out addEntriesFromDictionary:dictRep];
                    //[out addEntriesFromDictionary:nodeAttrs];
                }
            }
            // Attributes are not being combined with content here.
            // We need to handle nodes like <foo bar="whut">string content</foo>
            else
            {
                NSMutableArray *dictCollection = [NSMutableArray array];
                for(rawObj in objs)
                {
                    dictRep = [rawObj toDictionary];
                    id finalItems = [dictRep valueForKey:key];
                    [dictCollection addObject:finalItems];
                }
                
                collectionDict = [NSMutableDictionary dictionaryWithObject:dictCollection forKey:key];
                [out addEntriesFromDictionary:collectionDict];
            }
        }
        
        if([attrs count] > 0)
            [out addEntriesFromDictionary:attrs];
    }
    
    return [NSDictionary dictionaryWithObject:out forKey:elName];
}

// - (NSMutableDictionary *)toDictionary
// {
//     id out;
//     NSMutableDictionary *groups = [NSMutableDictionary dictionary];
//     NSXMLNode *node;
//     NSArray *nodes = [self children];
//    
//     // Create distinct arrays for items with the same name
//     //NSArray *keys = [self valueForKeyPath:@"children.@distinctUnionOfObjects.name"];
//     NSString *type = [[self attributesAsDictionary] valueForKey:@"type"];
//     
//     //NSLog(@"%s name:%@", _cmd, [self name]);
//     //NSLog(@"%s type:%@", _cmd, type);
//     
//     for(node in nodes) 
//     {
//         NSMutableArray *group;
//         NSString *elementName = [node name];
//         group = [groups objectForKey:elementName];
//         if(!group)
//         {
//             group = [NSMutableArray array];
//             [groups setObject:group forKey:elementName];
//         }
//         
//         [group addObject:node];
//     }
//     
//     if([self kind] == NSXMLTextKind)
//     {
//         NSLog(@"%s IS TEXT KIND:%@", _cmd, [node name]);
//     }
//     
//     // Array
//     if([type isEqualToString:@"array"])
//     {
//         out = [NSMutableArray array];
//         NSString *key;
//         for(key in groups)
//         {
//             id obj = [groups objectForKey:key];
//             if([obj count] == 1)
//             {
//                 NSLog(@"%s COUNT IS 1", _cmd);
//             } 
//             else
//             {
//                 for(id el in obj)
//                 {
//                     NSMutableDictionary *dict = [el toDictionary];
//                     id newObj = [dict valueForKey:key];
//                     [out addObject:newObj];
//                 }
//             }
//         }
//     
//     // NSDictionary    
//     } else {
//         out = [NSMutableDictionary dictionary];
//         NSString *key;
//         for(key in groups)
//         {
//             id obj = [groups objectForKey:key];            
//             if([obj count] == 1)
//             {
//                 id finalObj = [obj objectAtIndex:0]; 
//                 if([[finalObj children] count] > 0)
//                 {                    
//                     if([[finalObj childAtIndex:0] kind] == NSXMLTextKind)
//                     {                        
//                         id childObj = [finalObj childAtIndex:0];
//                         NSString *contents = [childObj stringValue];
//                         [out setObject:contents forKey:key];
//                     } 
//                     else 
//                     {                        
//                         NSMutableDictionary *subObj = [[finalObj toDictionary] valueForKey:key];
//                         [out setObject:subObj forKey:[finalObj name]];
//                     }
// 
//                 } 
//                 else
//                 {   
//                     //This is where nodes with no text value fall                  
//                     //NSString *contents = [finalObj stringValue];
//                     NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
//                     NSDictionary *attrs = [finalObj attributesAsDictionary];
//                     if([attrs count] > 0)
//                         [attrDict addEntriesFromDictionary:attrs];
//                         
//                     NSString *objName = [finalObj name];
//                     [out setObject:attrDict forKey:objName];
//                 }
//             } 
//             else
//             {
//                 NSMutableArray *subOut = [NSMutableArray array];
//                 for(id el in obj)
//                 {
//                     NSMutableDictionary *dict = [el toDictionary];
//                     NSMutableDictionary *aDict = [dict valueForKey:key];
//                     [subOut addObject:aDict];
//                     NSMutableDictionary *subDict = [NSMutableDictionary dictionaryWithObject:subOut forKey:key];
//                     [out addEntriesFromDictionary:subDict];
//                 }
//             }
//         }
//         
//         NSDictionary *attrs = [self attributesAsDictionary];
//         if([attrs count] > 0)
//             [out addEntriesFromDictionary:attrs];
//     }
//     
//     if(type && (out == nil))
//     {
//         NSLog(@"%s out is nil", _cmd);
//         return [NSMutableDictionary dictionary];
//     }
//     
//     return [NSMutableDictionary dictionaryWithObject:out forKey:[self name]];
// }
@end
