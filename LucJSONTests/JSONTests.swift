//
//  JSONTests.swift
//  LucJSON
//
//  Created by Oleksii on 10/03/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import XCTest
import LucJSON

class JSONTests: XCTestCase {
    
    func testJSONEquatable() {
        XCTAssertEqual(JSON(true), .bool(true))
        XCTAssertNotEqual(JSON(true), .bool(false))
        XCTAssertEqual(JSON(["firstName": .null]), .object(["firstName": .null]))
        XCTAssertNotEqual(JSON(["lastName": .null]), .object(["firstName": .null]))
        XCTAssertEqual(JSON("lastName"), .string("lastName"))
        XCTAssertEqual(JSON(2), .number(2.0))
        XCTAssertEqual(JSON(NSNumber(value: 2)), .number(2.0))
        XCTAssertEqual(JSON(2.0), .number(2.0))
        XCTAssertNotEqual(JSON(2), .number(2.2))
        XCTAssertNotEqual(JSON([.null, .number(2)]), .array([.null, .null]))
        XCTAssertNotEqual(JSON(2), .string("lastName"))
    }
    
    func testOptionalValues() {
        XCTAssertTrue(JSON.null.isNull)
        XCTAssertEqual(JSON.number(4).number, NSNumber(value: 4))
        XCTAssertEqual(JSON.bool(true).bool, true)
        XCTAssertEqual(JSON.string("test").string, "test")
        XCTAssertEqual(JSON.object(["test": .bool(true)]).object!, ["test": .bool(true)])
        XCTAssertEqual(JSON.array([.string("test"), .string("test")]).array!, [.string("test"), .string("test")])
        
        XCTAssertFalse(JSON.bool(true).isNull)
        XCTAssertNil(JSON.bool(true).number)
        XCTAssertNil(JSON.number(4).bool)
        XCTAssertNil(JSON.number(4).string)
        XCTAssertNil(JSON.number(4).object)
        XCTAssertNil(JSON.number(false).array)
    }
}
