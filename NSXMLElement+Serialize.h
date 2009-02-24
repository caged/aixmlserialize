//
//  NSXMLElement+Serialize.h
//  NSXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSXMLElement (Serialize)
- (NSDictionary *)attributesAsDictionary;
- (NSMutableDictionary *)toDictionary;
@end