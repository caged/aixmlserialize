//
//  NSXMLDocument+Serialize.m
//  NSXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "NSXMLDocument+Serialize.h"
#import "NSXMLElement+Serialize.h"

@implementation NSXMLDocument (Serialize)
- (NSDictionary *)toDictionary
{
   return [[self rootElement] toDictionary];
}
@end
