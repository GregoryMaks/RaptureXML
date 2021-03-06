//
//  XPathTests.m
//  RaptureXML
//
//  Created by John Blanco on 4/14/12.
//  Copyright (c) 2012 Rapture In Venice. All rights reserved.
//

#import "RXMLElement.h"

@interface XPathTests : SenTestCase {
    NSString *simplifiedXML_;
    NSString *attributedXML_;
    NSString *interruptedTextXML_;
    NSString *cdataXML_;
    NSString *multipleNestedXML_;
}

@end



@implementation XPathTests

- (void)setUp {
    simplifiedXML_ = @"\
    <shapes>\
    <square>Square</square>\
    <triangle>Triangle</triangle>\
    <circle>Circle</circle>\
    </shapes>";
    
    attributedXML_ = @"\
    <shapes>\
    <square name=\"Square\" />\
    <triangle name=\"Triangle\" />\
    <circle name=\"Circle\" />\
    </shapes>";
    interruptedTextXML_ = @"<top><a>this</a>is<a>interrupted</a>text<a></a></top>";
    cdataXML_ = @"<top><![CDATA[this]]><![CDATA[is]]><![CDATA[cdata]]></top>";
    
    multipleNestedXML_ = @"\
    <root>\
        <element1>\
            <element2 name='A1'/>\
            <element2 name='B1'/>\
            <element2 name='C1'/>\
        </element1>\
        <element1>\
            <element2 name='A2'/>\
            <element2 name='B2'/>\
            <element2 name='C2'/>\
        </element1>\
    </root>";
}

- (void)testBasicPath {
    __block NSInteger i = 0;

    RXMLElement *rxml = [RXMLElement elementFromXMLString:simplifiedXML_ encoding:NSUTF8StringEncoding];
    
    [rxml iterateWithRootXPath:@"//circle" usingBlock:^(RXMLElement *element) {
        STAssertEqualObjects(element.text, @"Circle", nil);
        i++;
    }];

    STAssertEquals(i, 1, nil);
}

- (void)testAttributePath {
    __block NSInteger i = 0;
    
    RXMLElement *rxml = [RXMLElement elementFromXMLString:attributedXML_ encoding:NSUTF8StringEncoding];
    
    [rxml iterateWithRootXPath:@"//circle[@name='Circle']" usingBlock:^(RXMLElement *element) {
        STAssertEqualObjects([element attribute:@"name"], @"Circle", nil);
        i++;
    }];
    
    STAssertEquals(i, 1, nil);
}

- (void)testRelativePath {
    RXMLElement *rxml = [RXMLElement elementFromXMLString:multipleNestedXML_ encoding:NSUTF8StringEncoding];
    
    NSArray *children = [rxml childrenWithXPath:@"/root" rootNode:NULL];
    STAssertEquals(children.count, (NSUInteger)1, nil);
    
    RXMLElement *rootXML = [children firstObject];
    STAssertEqualObjects([rootXML tag], @"root", nil);
    
    children = [rxml childrenWithXPath:@"./*" rootNode:rxml];
    STAssertEquals(children.count, (NSUInteger)2, nil);
    
    children = [rxml childrenWithXPath:@"./element1/*" rootNode:rxml];
    STAssertEquals(children.count, (NSUInteger)6, nil);
}

@end
