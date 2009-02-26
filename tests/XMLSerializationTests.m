//
//  XMLSerializationTests.m
//  NSXMLSerialize
//
//  Created by Justin Palmer on 2/26/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//
#import "XMLSerializationTests.h"
#import "NSXMLElement+Serialize.h"
#import "NSXMLDocument+Serialize.h"

@implementation XMLSerializationTests
- (void) setUp
{
    NSString *billXML  = [NSString stringWithContentsOfFile:@"fixtures/bill.xml"];
    NSString *tweetXML = [NSString stringWithContentsOfFile:@"fixtures/twitter.xml"];
    NSString *cmtXML   = [NSString stringWithContentsOfFile:@"fixtures/committees.xml"];
    
    NSXMLDocument *billDoc  = [[NSXMLDocument alloc] initWithXMLString:billXML options:NSXMLDocumentValidate error:nil];
    NSXMLDocument *tweetDoc = [[NSXMLDocument alloc] initWithXMLString:tweetXML options:NSXMLDocumentValidate error:nil];
    NSXMLDocument *cmtDoc   = [[NSXMLDocument alloc] initWithXMLString:cmtXML options:NSXMLDocumentValidate error:nil];

    billDict  = [billDoc toDictionary];
    tweetDict = [tweetDoc toDictionary];
    cmtDict   = [cmtDoc toDictionary];
    
}

- (void) testShouldCreateDictionaryFromXML 
{
    STAssertTrue([billDict isKindOfClass:[NSDictionary class]], nil);
}

- (void) testShouldCreateArrayFromChildrenIfTypeIsArray 
{
    STAssertTrue([[tweetDict valueForKey:@"statuses"] isKindOfClass:[NSArray class]], nil);
}

- (void)testShouldCreateArrayForItemsWithMultipleElementsOfTheSameName
{
    NSArray *actions = [billDict valueForKeyPath:@"bill.actions"];
    STAssertEquals([actions count], (NSUInteger)3, nil);
}

- (void)testShouldCreateContentKeyForElementsWithTextAndAttributes
{
    NSDictionary *title = [billDict valueForKeyPath:@"bill.titles.title"];
    STAssertEqualObjects([title objectForKey:@"type"], @"official", nil);
    STAssertEqualObjects([title objectForKey:@"content"], @"Providing for consideration of motions to suspend the rules, and for other purposes.", nil);
}

// Maybe this returns nil when we start type checking?
- (void)testShouldReturnEmptyStringForElementsWithNoAttributesOrContent:(id)anArgument
{
    NSDictionary *tweet = [[tweetDict valueForKey:@"statuses"] objectAtIndex:0];
    STAssertEqualObjects([tweet valueForKey:@"in_reply_to_status_id"], @"", nil);
}

// - (void)testShouldParseAttributesOnRootNode
// {
//     STFail(nil, nil);
// }
@end
