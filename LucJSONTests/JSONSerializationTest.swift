//
//  JSONSerializationTest.swift
//  LucJSON
//
//  Created by Oleksii on 10/03/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import XCTest
import LucJSON

class JSONSerializationTest: XCTestCase {
    
    let supportedEncodings: [String.Encoding] = [
        .utf8,
        .utf16, .utf16BigEndian,
        .utf32LittleEndian, .utf32BigEndian
    ]
    
    func test_JSONObjectWithData_emptyObject() {
        var bytes: [UInt8] = [0x7B, 0x7D]
        let subject = bytes.withUnsafeMutableBufferPointer {
            return Data(buffer: $0)
        }
        
        let object = try! JSON.Serialization.jsonObject(with: subject, options: []).object
        
        XCTAssertEqual(object?.count, 0)
    }
    
    //MARK: - Encoding Detection
    func test_JSONObjectWithData_encodingDetection() {
        let subjects: [(String, [UInt8])] = [
            // BOM Detection
            ("{} UTF-8 w/BOM", [0xEF, 0xBB, 0xBF, 0x7B, 0x7D]),
            ("{} UTF-16BE w/BOM", [0xFE, 0xFF, 0x0, 0x7B, 0x0, 0x7D]),
            ("{} UTF-16LE w/BOM", [0xFF, 0xFE, 0x7B, 0x0, 0x7D, 0x0]),
            ("{} UTF-32BE w/BOM", [0x00, 0x00, 0xFE, 0xFF, 0x0, 0x0, 0x0, 0x7B, 0x0, 0x0, 0x0, 0x7D]),
            ("{} UTF-32LE w/BOM", [0xFF, 0xFE, 0x00, 0x00, 0x7B, 0x0, 0x0, 0x0, 0x7D, 0x0, 0x0, 0x0]),
            
            // RFC4627 Detection
            ("{} UTF-8", [0x7B, 0x7D]),
            ("{} UTF-16BE", [0x0, 0x7B, 0x0, 0x7D]),
            ("{} UTF-16LE", [0x7B, 0x0, 0x7D, 0x0]),
            ("{} UTF-32BE", [0x0, 0x0, 0x0, 0x7B, 0x0, 0x0, 0x0, 0x7D]),
            ("{} UTF-32LE", [0x7B, 0x0, 0x0, 0x0, 0x7D, 0x0, 0x0, 0x0]),
            
            //            // Single Characters
            //            ("'3' UTF-8", [0x33]),
            //            ("'3' UTF-16BE", [0x0, 0x33]),
            //            ("'3' UTF-16LE", [0x33, 0x0]),
        ]
        
        for (description, encoded) in subjects {
            let result = try? JSON.Serialization.jsonObject(with: Data(bytes:encoded, count: encoded.count), options: [])
            XCTAssertNotNil(result, description)
        }
    }
    
}

//MARK: - JSONDeserialization
extension JSONSerializationTest {
    
    enum ObjectType {
        case data
        case stream
    }
    static var objectType = ObjectType.data
    
    func test_deserialize_emptyObject_withData() {
        deserialize_emptyObject(objectType: .data)
    }
    
    func test_deserialize_multiStringObject_withData() {
        deserialize_multiStringObject(objectType: .data)
    }
    
    func test_deserialize_emptyArray_withData() {
        deserialize_emptyArray(objectType: .data)
    }
    
    func test_deserialize_multiStringArray_withData() {
        deserialize_multiStringArray(objectType: .data)
    }
    
    
    func test_deserialize_unicodeString_withData() {
        deserialize_unicodeString(objectType: .data)
    }
    
    func test_deserialize_stringWithSpacesAtStart_withData() {
        deserialize_stringWithSpacesAtStart(objectType: .data)
    }
    
    func test_deserialize_values_withData() {
        deserialize_values(objectType: .data)
    }
    
    func test_deserialize_numbers_withData() {
        deserialize_numbers(objectType: .data)
    }
    
    func test_deserialize_simpleEscapeSequences_withData() {
        deserialize_simpleEscapeSequences(objectType: .data)
    }
    
    func test_deserialize_unicodeEscapeSequence_withData() {
        deserialize_unicodeEscapeSequence(objectType: .data)
    }
    
    func test_deserialize_unicodeSurrogatePairEscapeSequence_withData() {
        deserialize_unicodeSurrogatePairEscapeSequence(objectType: .data)
    }
    
    // Disabled due to uninitialized memory SR-606
    //    func test_deserialize_allowFragments_withData() {
    //        deserialize_allowFragments(objectType: .data)
    //    }
    
    func test_deserialize_unterminatedObjectString_withData() {
        deserialize_unterminatedObjectString(objectType: .data)
    }
    
    func test_deserialize_missingObjectKey_withData() {
        deserialize_missingObjectKey(objectType: .data)
    }
    
    func test_deserialize_unexpectedEndOfFile_withData() {
        deserialize_unexpectedEndOfFile(objectType: .data)
    }
    
    func test_deserialize_invalidValueInObject_withData() {
        deserialize_invalidValueInObject(objectType: .data)
    }
    
    func test_deserialize_invalidValueIncorrectSeparatorInObject_withData() {
        deserialize_invalidValueIncorrectSeparatorInObject(objectType: .data)
    }
    
    func test_deserialize_invalidValueInArray_withData() {
        deserialize_invalidValueInArray(objectType: .data)
    }
    
    func test_deserialize_badlyFormedArray_withData() {
        deserialize_badlyFormedArray(objectType: .data)
    }
    
    func test_deserialize_invalidEscapeSequence_withData() {
        deserialize_invalidEscapeSequence(objectType: .data)
    }
    
    func test_deserialize_unicodeMissingTrailingSurrogate_withData() {
        deserialize_unicodeMissingTrailingSurrogate(objectType: .data)
    }
    
    func test_deserialize_emptyObject_withStream() {
        deserialize_emptyObject(objectType: .stream)
    }
    
    func test_deserialize_multiStringObject_withStream() {
        deserialize_multiStringObject(objectType: .stream)
    }
    
    func test_deserialize_emptyArray_withStream() {
        deserialize_emptyArray(objectType: .stream)
    }
    
    func test_deserialize_multiStringArray_withStream() {
        deserialize_multiStringArray(objectType: .stream)
    }
    
    
    func test_deserialize_unicodeString_withStream() {
        deserialize_unicodeString(objectType: .stream)
    }
    
    func test_deserialize_stringWithSpacesAtStart_withStream() {
        deserialize_stringWithSpacesAtStart(objectType: .stream)
    }
    
    func test_deserialize_values_withStream() {
        deserialize_values(objectType: .stream)
    }
    
    func test_deserialize_numbers_withStream() {
        deserialize_numbers(objectType: .stream)
    }
    
    func test_deserialize_simpleEscapeSequences_withStream() {
        deserialize_simpleEscapeSequences(objectType: .stream)
    }
    
    func test_deserialize_unicodeEscapeSequence_withStream() {
        deserialize_unicodeEscapeSequence(objectType: .stream)
    }
    
    func test_deserialize_unicodeSurrogatePairEscapeSequence_withStream() {
        deserialize_unicodeSurrogatePairEscapeSequence(objectType: .stream)
    }
    
    // Disabled due to uninitialized memory SR-606
    //    func test_deserialize_allowFragments_withStream() {
    //        deserialize_allowFragments(objectType: .stream)
    //    }
    
    func test_deserialize_unterminatedObjectString_withStream() {
        deserialize_unterminatedObjectString(objectType: .stream)
    }
    
    func test_deserialize_missingObjectKey_withStream() {
        deserialize_missingObjectKey(objectType: .stream)
    }
    
    func test_deserialize_unexpectedEndOfFile_withStream() {
        deserialize_unexpectedEndOfFile(objectType: .stream)
    }
    
    func test_deserialize_invalidValueInObject_withStream() {
        deserialize_invalidValueInObject(objectType: .stream)
    }
    
    func test_deserialize_invalidValueIncorrectSeparatorInObject_withStream() {
        deserialize_invalidValueIncorrectSeparatorInObject(objectType: .stream)
    }
    
    func test_deserialize_invalidValueInArray_withStream() {
        deserialize_invalidValueInArray(objectType: .stream)
    }
    
    func test_deserialize_badlyFormedArray_withStream() {
        deserialize_badlyFormedArray(objectType: .stream)
    }
    
    func test_deserialize_invalidEscapeSequence_withStream() {
        deserialize_invalidEscapeSequence(objectType: .stream)
    }
    
    func test_deserialize_unicodeMissingTrailingSurrogate_withStream() {
        deserialize_unicodeMissingTrailingSurrogate(objectType: .stream)
    }
    
    //MARK: - Object Deserialization
    func deserialize_emptyObject(objectType: ObjectType) {
        let subject = "{}"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            
            let result = try getjsonObjectResult(data, objectType).object
            
            XCTAssertEqual(result?.count, 0)
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
    
    func deserialize_multiStringObject(objectType: ObjectType) {
        let subject = "{ \"hello\": \"world\", \"swift\": \"rocks\" }"
        do {
            for encoding in [String.Encoding.utf8, String.Encoding.utf16BigEndian] {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).object
                XCTAssertEqual(result?["hello"]?.string, "world")
                XCTAssertEqual(result?["swift"]?.string, "rocks")
            }
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
    
    func deserialize_stringWithSpacesAtStart(objectType: ObjectType) {
        let subject = "{\"title\" : \" hello world!!\" }"
        do {
            guard let data = subject.data(using: .utf8) else  {
                XCTFail("Unable to convert string to data")
                return
            }
            let result = try getjsonObjectResult(data, objectType).object
            XCTAssertEqual(result?["title"]?.string, " hello world!!")
        } catch{
            XCTFail("Error thrown: \(error)")
        }
    }
    
    //MARK: - Array Deserialization
    func deserialize_emptyArray(objectType: ObjectType) {
        let subject = "[]"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let result = try getjsonObjectResult(data, objectType).array
            XCTAssertEqual(result?.count, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func deserialize_multiStringArray(objectType: ObjectType) {
        let subject = "[\"hello\", \"swift⚡️\"]"
        
        do {
            for encoding in [String.Encoding.utf8, String.Encoding.utf16BigEndian] {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).array
                XCTAssertEqual(result?[0].string, "hello")
                XCTAssertEqual(result?[1].string, "swift⚡️")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func deserialize_unicodeString(objectType: ObjectType) {
        /// Ģ has the same LSB as quotation mark " (U+0022) so test guarding against this case
        let subject = "[\"unicode\", \"Ģ\", \"😢\"]"
        do {
            for encoding in [String.Encoding.utf16LittleEndian, String.Encoding.utf16BigEndian, String.Encoding.utf32LittleEndian, String.Encoding.utf32BigEndian] {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).array
                XCTAssertEqual(result?[0].string, "unicode")
                XCTAssertEqual(result?[1].string, "Ģ")
                XCTAssertEqual(result?[2].string, "😢")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    //MARK: - Value parsing
    func deserialize_values(objectType: ObjectType) {
        let subject = "[true, false, \"hello\", null, {}, []]"
        
        do {
            for encoding in supportedEncodings {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).array
                XCTAssertEqual(result?[0].bool, true)
                XCTAssertEqual(result?[1].bool, false)
                XCTAssertEqual(result?[2].string, "hello")
                XCTAssertTrue(result?[3].isNull ?? false)
                XCTAssertNotNil(result?[4].object)
                XCTAssertNotNil(result?[5].array)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    //MARK: - Number parsing
    func deserialize_numbers(objectType: ObjectType) {
        let subject = "[1, -1, 1.3, -1.3, 1e3, 1E-3]"
        
        do {
            for encoding in supportedEncodings {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).array
                XCTAssertEqual(result?[0].number,     1)
                XCTAssertEqual(result?[1].number,    -1)
                XCTAssertEqual(result?[2].number,   1.3)
                XCTAssertEqual(result?[3].number,  -1.3)
                XCTAssertEqual(result?[4].number,  1000)
                XCTAssertEqual(result?[5].number, 0.001)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    //MARK: - Escape Sequences
    func deserialize_simpleEscapeSequences(objectType: ObjectType) {
        let subject = "[\"\\\"\", \"\\\\\", \"\\/\", \"\\b\", \"\\f\", \"\\n\", \"\\r\", \"\\t\"]"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let res = try getjsonObjectResult(data, objectType).array
            let result = res?.flatMap { $0.string }
            XCTAssertEqual(result?[0], "\"")
            XCTAssertEqual(result?[1], "\\")
            XCTAssertEqual(result?[2], "/")
            XCTAssertEqual(result?[3], "\u{08}")
            XCTAssertEqual(result?[4], "\u{0C}")
            XCTAssertEqual(result?[5], "\u{0A}")
            XCTAssertEqual(result?[6], "\u{0D}")
            XCTAssertEqual(result?[7], "\u{09}")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func deserialize_unicodeEscapeSequence(objectType: ObjectType) {
        let subject = "[\"\\u2728\"]"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let result = try getjsonObjectResult(data, objectType).array
            // result?[0] as? String returns an Optional<String> and RHS is promoted
            // to Optional<String>
            XCTAssertEqual(result?[0].string, "✨")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func deserialize_unicodeSurrogatePairEscapeSequence(objectType: ObjectType) {
        let subject = "[\"\\uD834\\udd1E\"]"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let result = try getjsonObjectResult(data, objectType).array
            // result?[0] as? String returns an Optional<String> and RHS is promoted
            // to Optional<String>
            XCTAssertEqual(result?[0].string, "\u{1D11E}")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func deserialize_allowFragments(objectType: ObjectType) {
        let subject = "3"
        
        do {
            for encoding in supportedEncodings {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let result = try getjsonObjectResult(data, objectType).number
                XCTAssertEqual(result, 3)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    //MARK: - Parsing Errors
    func deserialize_unterminatedObjectString(objectType: ObjectType) {
        let subject = "{\"}"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: UnterminatedString")
        } catch {
            // Passing case; the object as unterminated
        }
    }
    
    func deserialize_missingObjectKey(objectType: ObjectType) {
        let subject = "{3}"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Missing key for value")
        } catch {
            // Passing case; the key was missing for a value
        }
    }
    
    func deserialize_unexpectedEndOfFile(objectType: ObjectType) {
        let subject = "{"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Unexpected end of file")
        } catch {
            // Success
        }
    }
    
    func deserialize_invalidValueInObject(objectType: ObjectType) {
        let subject = "{\"error\":}"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Invalid value")
        } catch {
            // Passing case; the value is invalid
        }
    }
    
    func deserialize_invalidValueIncorrectSeparatorInObject(objectType: ObjectType) {
        let subject = "{\"missing\";}"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Invalid value")
        } catch {
            // passing case the value is invalid
        }
    }
    
    func deserialize_invalidValueInArray(objectType: ObjectType) {
        let subject = "[,"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Invalid value")
        } catch {
            // Passing case; the element in the array is missing
        }
    }
    
    func deserialize_badlyFormedArray(objectType: ObjectType) {
        let subject = "[2b4]"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Badly formed array")
        } catch {
            // Passing case; the array is malformed
        }
    }
    
    func deserialize_invalidEscapeSequence(objectType: ObjectType) {
        let subject = "[\"\\e\"]"
        
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType)
            XCTFail("Expected error: Invalid escape sequence")
        } catch {
            // Passing case; the escape sequence is invalid
        }
    }
    
    func deserialize_unicodeMissingTrailingSurrogate(objectType: ObjectType) {
        let subject = "[\"\\uD834\"]"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let _ = try getjsonObjectResult(data, objectType).array?.flatMap { $0.string }
            XCTFail("Expected error: Missing Trailing Surrogate")
        } catch {
            // Passing case; the unicode character is malformed
        }
    }
    
    func test_JSONObjectWithStream_withFile() {
        let subject = "{}"
        do {
            guard let data = subject.data(using: .utf8) else {
                XCTFail("Unable to convert string to data")
                return
            }
            let filePath = createTestFile("TestJSON.txt",_contents: data)
            if filePath != nil {
                let fileStream: InputStream = InputStream(fileAtPath: filePath!)!
                fileStream.open()
                let resultRead = try JSON.Serialization.jsonObject(with: fileStream, options: [])
                let result = resultRead.object
                XCTAssertEqual(result?.count, 0)
                fileStream.close()
                removeTestFile(filePath!)
            }
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
    
    func test_JSONObjectWithStream_withURL() {
        let subject = "[true, false, \"hello\", null, {}, []]"
        do {
            for encoding in supportedEncodings {
                guard let data = subject.data(using: encoding) else {
                    XCTFail("Unable to convert string to data")
                    return
                }
                let filePath = createTestFile("TestJSON.txt",_contents: data)
                if filePath != nil {
                    let url = URL(fileURLWithPath: filePath!)
                    let inputStream: InputStream = InputStream(url: url)!
                    inputStream.open()
                    let result = try JSON.Serialization.jsonObject(with: inputStream, options: []).array
                    inputStream.close()
                    removeTestFile(filePath!)
                    XCTAssertEqual(result?[0].bool, true)
                    XCTAssertEqual(result?[1].bool, false)
                    XCTAssertEqual(result?[2].string, "hello")
                    XCTAssertTrue(result?[3].isNull ?? false)
                    XCTAssertNotNil(result?[4].object)
                    XCTAssertNotNil(result?[5].array)
                }
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    
    private func getjsonObjectResult(_ data: Data,_ objectType: ObjectType) throws -> JSON {
        var result: JSON
        switch objectType {
        case .data:
            //Test with Data
            result = try JSON.Serialization.jsonObject(with: data, options: [])
        case .stream:
            //Test with stream
            let stream: InputStream = InputStream(data: data)
            stream.open()
            result = try JSON.Serialization.jsonObject(with: stream, options: [])
            stream.close()
        }
        return result
    }
}

extension JSONSerializationTest {
    func trySerialize(_ obj: JSON) throws -> String {
        let data = try JSON.Serialization.data(withJSON: obj, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            XCTFail("Unable to create string")
            return ""
        }
        return string
    }
    
    func test_serialize_emptyObject() {
        XCTAssertEqual(try trySerialize(.object([:])), "{}")
        XCTAssertEqual(try trySerialize(.array([])), "[]")
    }
    
    //[SR-2151] https://bugs.swift.org/browse/SR-2151
    //NSJSONSerialization.data(withJSONObject:options) produces illegal JSON code
    func test_serialize_dictionaryWithDecimal() {
        
        //test serialize values less than 1 with maxFractionDigits = 15
        func excecute_testSetLessThanOne() {
            //expected : input to be serialized
            let params  = [
                ("0.1",0.1),
                ("0.2",0.2),
                ("0.3",0.3),
                ("0.4",0.4),
                ("0.5",0.5),
                ("0.6",0.6),
                ("0.7",0.7),
                ("0.8",0.8),
                ("0.9",0.9),
                ("0.23456789012345",0.23456789012345),
                
                ("-0.1",-0.1),
                ("-0.2",-0.2),
                ("-0.3",-0.3),
                ("-0.4",-0.4),
                ("-0.5",-0.5),
                ("-0.6",-0.6),
                ("-0.7",-0.7),
                ("-0.8",-0.8),
                ("-0.9",-0.9),
                ("-0.23456789012345",-0.23456789012345),
                ]
            for param in params {
                let testDict = JSON([param.0: JSON(param.1)])
                let str = try? trySerialize(testDict)
                XCTAssertEqual(str!, "{\"\(param.0)\":\(param.1)}", "serialized value should  have a decimal places and leading zero")
            }
        }
        //test serialize values grater than 1 with maxFractionDigits = 15
        func excecute_testSetGraterThanOne() {
            let paramsBove1 = [
                ("1.1",1.1),
                ("1.2",1.2),
                ("1.23456789012345",1.23456789012345),
                ("-1.1",-1.1),
                ("-1.2",-1.2),
                ("-1.23456789012345",-1.23456789012345),
                ]
            for param in paramsBove1 {
                let testDict: JSON = JSON([param.0: JSON(param.1)])
                let str = try? trySerialize(testDict)
                XCTAssertEqual(str!, "{\"\(param.0)\":\(param.1)}", "serialized Double should  have a decimal places and leading value")
            }
        }
        
        //test serialize values for whole integer where the input is in Double format
        func excecute_testWholeNumbersWithDoubleAsInput() {
            
            let paramsWholeNumbers = [
                ("-1"  ,-1.0),
                ("0"  ,0.0),
                ("1"  ,1.0),
                ]
            for param in paramsWholeNumbers {
                let testDict: JSON = JSON([param.0: JSON(param.1)])
                let str = try? trySerialize(testDict)
                XCTAssertEqual(str!, "{\"\(param.0)\":\(NSString(string:param.0).intValue)}", "expect that serialized value should not contain trailing zero or decimal as they are whole numbers ")
            }
        }
        
        func excecute_testWholeNumbersWithIntInput() {
            for i  in -10..<10 {
                let iStr = "\(i)"
                let testDict: JSON = .object([iStr : .number(NSNumber(value: i))])
                let str = try? trySerialize(testDict)
                XCTAssertEqual(str!, "{\"\(iStr)\":\(i)}", "expect that serialized value should not contain trailing zero or decimal as they are whole numbers ")
            }
        }
        excecute_testSetLessThanOne()
        excecute_testSetGraterThanOne()
        excecute_testWholeNumbersWithDoubleAsInput()
        excecute_testWholeNumbersWithIntInput()
    }
    
    func test_serialize_null() {
        let arr = JSON([.null])
        XCTAssertEqual(try trySerialize(arr), "[null]")
        
        let dict = JSON(["a": .null])
        XCTAssertEqual(try trySerialize(dict), "{\"a\":null}")
        
        let arr2 = JSON([.null, .null, .null])
        XCTAssertEqual(try trySerialize(arr2), "[null,null,null]")
        
        let dict2 = JSON([JSON(["a": .null]), JSON(["b": .null]), JSON(["c": .null])])
        XCTAssertEqual(try trySerialize(dict2), "[{\"a\":null},{\"b\":null},{\"c\":null}]")
    }
    
    func test_serialize_complexObject() {
        let jsonDict = JSON(["a": JSON(4)])
        XCTAssertEqual(try trySerialize(jsonDict), "{\"a\":4}")
        
        let jsonArr = JSON([JSON(1), JSON(2), JSON(3), JSON(4)])
        XCTAssertEqual(try trySerialize(jsonArr), "[1,2,3,4]")
        
        let jsonDict2 = JSON(["a": JSON([JSON(1), JSON(2)])])
        XCTAssertEqual(try trySerialize(jsonDict2), "{\"a\":[1,2]}")
        
        let jsonArr2 = JSON([JSON("a"), JSON("b"), JSON("c")])
        XCTAssertEqual(try trySerialize(jsonArr2), "[\"a\",\"b\",\"c\"]")
        
        let jsonArr3 = JSON([JSON(["a": JSON(1)]), JSON(["b": JSON(2)])])
        XCTAssertEqual(try trySerialize(jsonArr3), "[{\"a\":1},{\"b\":2}]")
        
        let jsonArr4 = JSON([JSON(["a": .null]), JSON(["b": .null])])
        XCTAssertEqual(try trySerialize(jsonArr4), "[{\"a\":null},{\"b\":null}]")
    }
    
    func test_nested_array() {
        var arr = JSON([JSON("a")])
        XCTAssertEqual(try trySerialize(arr), "[\"a\"]")
        
        arr = JSON([JSON([JSON("b")])])
        XCTAssertEqual(try trySerialize(arr), "[[\"b\"]]")
        
        arr = JSON([JSON([JSON([JSON("c")])])])
        XCTAssertEqual(try trySerialize(arr), "[[[\"c\"]]]")
        
        arr = .array([.array([.array([.array([JSON("d")])])])])
        XCTAssertEqual(try trySerialize(arr), "[[[[\"d\"]]]]")
    }
    
    func test_nested_dictionary() {
        var dict: JSON = .object(["a": .number(NSNumber(value:1))])
        XCTAssertEqual(try trySerialize(dict), "{\"a\":1}")
        
        dict = .object(["a": .object(["b": .number(NSNumber(value:1))])])
        XCTAssertEqual(try trySerialize(dict), "{\"a\":{\"b\":1}}")
        
        dict = .object(["a": .object(["b": .object(["c": .number(NSNumber(value:1))])])])
        XCTAssertEqual(try trySerialize(dict), "{\"a\":{\"b\":{\"c\":1}}}")
        
        dict = .object(["a": .object(["b": .object(["c": .object(["d": JSON(1)])])])])
        XCTAssertEqual(try trySerialize(dict), "{\"a\":{\"b\":{\"c\":{\"d\":1}}}}")
    }
    
    func test_serialize_number() {
        let json: JSON = .array([.number(NSNumber(value:1)), .number(NSNumber(value:1.1)), .number(NSNumber(value:0)), .number(NSNumber(value:-2))])
        XCTAssertEqual(try trySerialize(json), "[1,1.1,0,-2]")
    }
    
    func test_serialize_stringEscaping() {
        var json = JSON([.string("foo")])
        XCTAssertEqual(try trySerialize(json), "[\"foo\"]")
        
        json = JSON([.string("a\0")])
        XCTAssertEqual(try trySerialize(json), "[\"a\\u0000\"]")
        
        json = JSON([.string("b\\")])
        XCTAssertEqual(try trySerialize(json), "[\"b\\\\\"]")
        
        json = JSON([.string("c\t")])
        XCTAssertEqual(try trySerialize(json), "[\"c\\t\"]")
        
        json = JSON([.string("d\n")])
        XCTAssertEqual(try trySerialize(json), "[\"d\\n\"]")
        
        json = JSON([.string("e\r")])
        XCTAssertEqual(try trySerialize(json), "[\"e\\r\"]")
        
        json = JSON([.string("f\"")])
        XCTAssertEqual(try trySerialize(json), "[\"f\\\"\"]")
        
        json = JSON([.string("g\'")])
        XCTAssertEqual(try trySerialize(json), "[\"g\'\"]")
        
        json = JSON([.string("h\u{7}")])
        XCTAssertEqual(try trySerialize(json), "[\"h\\u0007\"]")
        
        json = JSON([.string("i\u{1f}")])
        XCTAssertEqual(try trySerialize(json), "[\"i\\u001f\"]")
    }
    
    /* These are a programming error and should not be done
     Ideally the interface for JSONSerialization should at compile time prevent this type of thing
     by overloading the interface such that it can only accept dictionaries and arrays.
     func test_serialize_invalid_json() {
     let str = "Invalid JSON"
     do {
     let _ = try trySerialize(str)
     XCTFail("Top-level JSON object cannot be string")
     } catch {
     // should get here
     }
     
     let double = NSNumber(value: Double(1.2))
     do {
     let _ = try trySerialize(double)
     XCTFail("Top-level JSON object cannot be double")
     } catch {
     // should get here
     }
     
     let dict = [NSNumber(value: Double(1.2)):"a"]
     do {
     let _ = try trySerialize(dict)
     XCTFail("Dictionary keys must be strings")
     } catch {
     // should get here
     }
     }
     */
    
    func test_jsonReadingOffTheEndOfBuffers() {
        let data = "12345679".data(using: .utf8)!
        do {
            let res = try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> JSON in
                let slice = Data(bytesNoCopy: UnsafeMutablePointer(mutating: bytes), count: 1, deallocator: .none)
                return try JSON.Serialization.jsonObject(with: slice, options: .allowFragments)
            }
            if let num = res.number {
                XCTAssertEqual(1, num) // the slice truncation should only parse 1 byte!
            } else {
                XCTFail("expected an integer but got a \(res)")
            }
        } catch {
            XCTFail("Unknow json decoding failure")
        }
    }
    
    func test_jsonObjectToOutputStreamBuffer(){
        let dict = JSON(["a": JSON(["b": JSON(1)])])
        do {
            let buffer = Array<UInt8>(repeating: 0, count: 13)
            let outputStream = OutputStream(toBuffer: UnsafeMutablePointer(mutating: buffer), capacity: 13)
            outputStream.open()
            let result = try JSON.Serialization.writeJSONObject(dict, toStream: outputStream, options: [])
            outputStream.close()
            if(result > -1) {
                XCTAssertEqual(String(bytes: buffer, encoding: .utf8), "{\"a\":{\"b\":1}}")
            }
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
    
    func test_jsonObjectToOutputStreamFile() {
        let dict: JSON = .object(["a": .object(["b": .number(NSNumber(value: 1))])])
        do {
            let filePath = createTestFile("TestFileOut.txt",_contents: Data(capacity: 128))
            if filePath != nil {
                let outputStream = OutputStream(toFileAtPath: filePath!, append: true)
                outputStream?.open()
                let result = try JSON.Serialization.writeJSONObject(dict, toStream: outputStream!, options: [])
                outputStream?.close()
                if(result > -1) {
                    let fileStream: InputStream = InputStream(fileAtPath: filePath!)!
                    var buffer = [UInt8](repeating: 0, count: 13)
                    fileStream.open()
                    if fileStream.hasBytesAvailable {
                        let resultRead: Int = fileStream.read(&buffer, maxLength: buffer.count)
                        fileStream.close()
                        if(resultRead > -1){
                            XCTAssertEqual(String(bytes: buffer, encoding: .utf8), "{\"a\":{\"b\":1}}")
                        }
                    }
                    removeTestFile(filePath!)
                } else {
                    XCTFail("Unable to create temp file")
                }
            }
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
    
    func test_jsonObjectToOutputStreamInsufficientBuffer() {
        let dict: JSON = .object(["a": .object(["b": .number(NSNumber(value: 1))])])
        let buffer = Array<UInt8>(repeating: 0, count: 10)
        let outputStream = OutputStream(toBuffer: UnsafeMutablePointer(mutating: buffer), capacity: buffer.count)
        outputStream.open()
        do {
            let result = try JSON.Serialization.writeJSONObject(dict, toStream: outputStream, options: [])
            outputStream.close()
            if(result > -1) {
                XCTAssertNotEqual(NSString(bytes: buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue), "{\"a\":{\"b\":1}}")
            }
        } catch {
            XCTFail("Error occurred while writing to stream")
        }
    }
    
//    func test_invalidJsonObjectToStreamBuffer() {
//        let str = JSON.string("Invalid JSON")
//        let buffer = Array<UInt8>(repeating: 0, count: 10)
//        let outputStream = OutputStream(toBuffer: UnsafeMutablePointer(mutating: buffer), capacity: buffer.count)
//        outputStream.open()
//        XCTAssertThrowsError(try JSON.Serialization.writeJSONObject(str, toStream: outputStream, options: []))
//    }
    
    func test_booleanJSONObject() {
        do {
            let objectLikeBoolArray = try JSONSerialization.data(withJSONObject: [true, NSNumber(value: false), NSNumber(value: true)] as Array<Any>)
            XCTAssertEqual(String(data: objectLikeBoolArray, encoding: .utf8), "[true,false,true]")
            let valueLikeBoolArray = try JSONSerialization.data(withJSONObject: [false, true, false])
            XCTAssertEqual(String(data: valueLikeBoolArray, encoding: .utf8), "[false,true,false]")
        } catch {
            XCTFail("Failed during serialization")
        }
        XCTAssertTrue(JSONSerialization.isValidJSONObject([true]))
    }
}

extension JSONSerializationTest {
    fileprivate func createTestFile(_ path: String,_contents: Data) -> String? {
        let tempDir = NSTemporaryDirectory() + "TestFoundation_Playground_" + NSUUID().uuidString + "/"
        do {
            try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: false, attributes: nil)
            if FileManager.default.createFile(atPath: tempDir + "/" + path, contents: _contents,
                                              attributes: nil) {
                return tempDir + path
            } else {
                return nil
            }
        } catch _ {
            return nil
        }
    }
    
    fileprivate func removeTestFile(_ location: String) {
        do {
            try FileManager.default.removeItem(atPath: location)
        } catch _ {
            
        }
    }
}
