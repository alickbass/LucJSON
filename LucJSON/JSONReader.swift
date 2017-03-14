//
//  JSONReader.swift
//  LucJSON
//
//  Created by Oleksii on 10/03/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import CoreFoundation

#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux) || CYGWIN
    import Glibc
#endif

extension JSON {
    struct Reader {
        
        static let whitespaceASCII: [UInt8] = [
            0x09, // Horizontal tab
            0x0A, // Line feed or New line
            0x0D, // Carriage return
            0x20, // Space
        ]
        
        struct Structure {
            static let BeginArray: UInt8     = 0x5B // [
            static let EndArray: UInt8       = 0x5D // ]
            static let BeginObject: UInt8    = 0x7B // {
            static let EndObject: UInt8      = 0x7D // }
            static let NameSeparator: UInt8  = 0x3A // :
            static let ValueSeparator: UInt8 = 0x2C // ,
            static let QuotationMark: UInt8  = 0x22 // "
            static let Escape: UInt8         = 0x5C // \
        }
        
        typealias Index = Int
        typealias IndexDistance = Int
        
        struct UnicodeSource {
            let buffer: UnsafeBufferPointer<UInt8>
            let encoding: String.Encoding
            let step: Int
            
            init(buffer: UnsafeBufferPointer<UInt8>, encoding: String.Encoding) {
                self.buffer = buffer
                self.encoding = encoding
                
                self.step = {
                    switch encoding {
                    case String.Encoding.utf8:
                        return 1
                    case String.Encoding.utf16BigEndian, String.Encoding.utf16LittleEndian:
                        return 2
                    case String.Encoding.utf32BigEndian, String.Encoding.utf32LittleEndian:
                        return 4
                    default:
                        return 1
                    }
                }()
            }
            
            func takeASCII(_ input: Index) -> (UInt8, Index)? {
                guard hasNext(input) else {
                    return nil
                }
                
                let index: Int
                switch encoding {
                case String.Encoding.utf8:
                    index = input
                case String.Encoding.utf16BigEndian where buffer[input] == 0:
                    index = input + 1
                case String.Encoding.utf32BigEndian where buffer[input] == 0 && buffer[input+1] == 0 && buffer[input+2] == 0:
                    index = input + 3
                case String.Encoding.utf16LittleEndian where buffer[input+1] == 0:
                    index = input
                case String.Encoding.utf32LittleEndian where buffer[input+1] == 0 && buffer[input+2] == 0 && buffer[input+3] == 0:
                    index = input
                default:
                    return nil
                }
                return (buffer[index] < 0x80) ? (buffer[index], input + step) : nil
            }
            
            func takeString(_ begin: Index, end: Index) throws -> String {
                let byteLength = begin.distance(to: end)
                
                guard let chunk = String(data: Data(bytes: buffer.baseAddress!.advanced(by: begin), count: byteLength), encoding: encoding) else {
                    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                        "NSDebugDescription" : "Unable to convert data to a string using the detected encoding. The data may be corrupt."
                        ])
                }
                return chunk
            }
            
            func hasNext(_ input: Index) -> Bool {
                return input + step <= buffer.endIndex
            }
            
            func distanceFromStart(_ index: Index) -> IndexDistance {
                return buffer.startIndex.distance(to: index) / step
            }
        }
        
        let source: UnicodeSource
        
        func consumeWhitespace(_ input: Index) -> Index? {
            var index = input
            while let (char, nextIndex) = source.takeASCII(index), Reader.whitespaceASCII.contains(char) {
                index = nextIndex
            }
            return index
        }
        
        func consumeStructure(_ ascii: UInt8, input: Index) throws -> Index? {
            return try consumeWhitespace(input).flatMap(consumeASCII(ascii)).flatMap(consumeWhitespace)
        }
        
        func consumeASCII(_ ascii: UInt8) -> (Index) throws -> Index? {
            return { (input: Index) throws -> Index? in
                switch self.source.takeASCII(input) {
                case .none:
                    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                        "NSDebugDescription" : "Unexpected end of file during JSON parse."
                        ])
                case let (taken, index)? where taken == ascii:
                    return index
                default:
                    return nil
                }
            }
        }
        
        func consumeASCIISequence(_ sequence: String, input: Index) throws -> Index? {
            var index = input
            for scalar in sequence.unicodeScalars {
                guard let nextIndex = try consumeASCII(UInt8(scalar.value))(index) else {
                    return nil
                }
                index = nextIndex
            }
            return index
        }
        
        func takeMatching(_ match: @escaping (UInt8) -> Bool) -> ([Character], Index) -> ([Character], Index)? {
            return { input, index in
                guard let (byte, index) = self.source.takeASCII(index), match(byte) else {
                    return nil
                }
                return (input + [Character(UnicodeScalar(byte))], index)
            }
        }
        
        //MARK: - String Parsing
        func parseString(_ input: Index) throws -> (String, Index)? {
            guard let beginIndex = try consumeWhitespace(input).flatMap(consumeASCII(Structure.QuotationMark)) else {
                return nil
            }
            var chunkIndex: Int = beginIndex
            var currentIndex: Int = chunkIndex
            
            var output: String = ""
            while source.hasNext(currentIndex) {
                guard let (ascii, index) = source.takeASCII(currentIndex) else {
                    currentIndex += source.step
                    continue
                }
                switch ascii {
                case Structure.QuotationMark:
                    output += try source.takeString(chunkIndex, end: currentIndex)
                    return (output, index)
                case Structure.Escape:
                    output += try source.takeString(chunkIndex, end: currentIndex)
                    if let (escaped, nextIndex) = try parseEscapeSequence(index) {
                        output += escaped
                        chunkIndex = nextIndex
                        currentIndex = nextIndex
                        continue
                    }
                    else {
                        throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                            "NSDebugDescription" : "Invalid escape sequence at position \(source.distanceFromStart(currentIndex))"
                            ])
                    }
                default:
                    currentIndex = index
                }
            }
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                "NSDebugDescription" : "Unexpected end of file during string parse."
                ])
        }
        
        func parseEscapeSequence(_ input: Index) throws -> (String, Index)? {
            guard let (byte, index) = source.takeASCII(input) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Early end of unicode escape sequence around character"
                    ])
            }
            let output: String
            switch byte {
            case 0x22: output = "\""
            case 0x5C: output = "\\"
            case 0x2F: output = "/"
            case 0x62: output = "\u{08}" // \b
            case 0x66: output = "\u{0C}" // \f
            case 0x6E: output = "\u{0A}" // \n
            case 0x72: output = "\u{0D}" // \r
            case 0x74: output = "\u{09}" // \t
            case 0x75: return try parseUnicodeSequence(index)
            default: return nil
            }
            return (output, index)
        }
        
        func parseUnicodeSequence(_ input: Index) throws -> (String, Index)? {
            
            guard let (codeUnit, index) = parseCodeUnit(input) else {
                return nil
            }
            
            if !UTF16.isLeadSurrogate(codeUnit) {
                return (String(UnicodeScalar(codeUnit)!), index)
            }
            
            guard let (trailCodeUnit, finalIndex) = try consumeASCIISequence("\\u", input: index).flatMap(parseCodeUnit) , UTF16.isTrailSurrogate(trailCodeUnit) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Unable to convert unicode escape sequence (no low-surrogate code point) to UTF8-encoded character at position \(source.distanceFromStart(input))"
                    ])
            }
            
            let highValue = (UInt32(codeUnit  - 0xD800) << 10)
            let lowValue  =  UInt32(trailCodeUnit - 0xDC00)
            return (String(UnicodeScalar(highValue + lowValue + 0x10000)!), finalIndex)
        }
        
        func isHexChr(_ byte: UInt8) -> Bool {
            return (byte >= 0x30 && byte <= 0x39)
                || (byte >= 0x41 && byte <= 0x46)
                || (byte >= 0x61 && byte <= 0x66)
        }
        func parseCodeUnit(_ input: Index) -> (UTF16.CodeUnit, Index)? {
            let hexParser = takeMatching(isHexChr)
            guard let (result, index) = hexParser([], input).flatMap(hexParser).flatMap(hexParser).flatMap(hexParser),
                let value = Int(String(result), radix: 16) else {
                    return nil
            }
            return (UTF16.CodeUnit(value), index)
        }
        
        //MARK: - Number parsing
        static let numberCodePoints: [UInt8] = [
            0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, // 0...9
            0x2E, 0x2D, 0x2B, 0x45, 0x65, // . - + E e
        ]
        func parseNumber(_ input: Index) throws -> (NSNumber, Index)? {
            func parseTypedNumber(_ address: UnsafePointer<UInt8>, count: Int) -> (NSNumber, IndexDistance)? {
                let temp_buffer_size = 64
                var temp_buffer = [Int8](repeating: 0, count: temp_buffer_size)
                return temp_buffer.withUnsafeMutableBufferPointer { (buffer: inout UnsafeMutableBufferPointer<Int8>) -> (NSNumber, IndexDistance)? in
                    memcpy(buffer.baseAddress!, address, min(count, temp_buffer_size - 1)) // ensure null termination
                    
                    let startPointer = buffer.baseAddress!
                    let intEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
                    defer { intEndPointer.deallocate(capacity: 1) }
                    let doubleEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
                    defer { doubleEndPointer.deallocate(capacity: 1) }
                    
                    let intResult = strtol(startPointer, intEndPointer, 10)
                    let intDistance = startPointer.distance(to: intEndPointer[0]!)
                    let doubleResult = strtod(startPointer, doubleEndPointer)
                    let doubleDistance = startPointer.distance(to: doubleEndPointer[0]!)
                    
                    guard intDistance > 0 || doubleDistance > 0 else {
                        return nil
                    }
                    
                    if intDistance == doubleDistance {
                        return (NSNumber(value: intResult), intDistance)
                    }
                    guard doubleDistance > 0 else {
                        return nil
                    }
                    return (NSNumber(value: doubleResult), doubleDistance)
                }
            }
            
            if source.encoding == String.Encoding.utf8 {
                
                return parseTypedNumber(source.buffer.baseAddress!.advanced(by: input), count: source.buffer.count - input).map { return ($0.0, input + $0.1) }
            }
            else {
                var numberCharacters = [UInt8]()
                var index = input
                while let (ascii, nextIndex) = source.takeASCII(index), Reader.numberCodePoints.contains(ascii) {
                    numberCharacters.append(ascii)
                    index = nextIndex
                }
                
                numberCharacters.append(0)
                
                return numberCharacters.withUnsafeBufferPointer {
                    parseTypedNumber($0.baseAddress!, count: $0.count)
                    }.map { return ($0.0, index) }
            }
        }
        
        //MARK: - Value parsing
        func parseValue(_ input: Index) throws -> (JSON, Index)? {
            if let (value, parser) = try parseString(input) {
                return (.string(value), parser)
            }
            else if let parser = try consumeASCIISequence("true", input: input) {
                return (.bool(true), parser)
            }
            else if let parser = try consumeASCIISequence("false", input: input) {
                return (.bool(false), parser)
            }
            else if let parser = try consumeASCIISequence("null", input: input) {
                return (.null, parser)
            }
            else if let (object, parser) = try parseObject(input) {
                return (.object(object), parser)
            }
            else if let (array, parser) = try parseArray(input) {
                return (.array(array), parser)
            }
            else if let (number, parser) = try parseNumber(input) {
                return (.number(number), parser)
            }
            return nil
        }
        
        //MARK: - Object parsing
        func parseObject(_ input: Index) throws -> ([String: JSON], Index)? {
            guard let beginIndex = try consumeStructure(Structure.BeginObject, input: input) else {
                return nil
            }
            var index = beginIndex
            var output: [String: JSON] = [:]
            while true {
                if let finalIndex = try consumeStructure(Structure.EndObject, input: index) {
                    return (output, finalIndex)
                }
                
                if let (key, value, nextIndex) = try parseObjectMember(index) {
                    output[key] = value
                    
                    if let finalParser = try consumeStructure(Structure.EndObject, input: nextIndex) {
                        return (output, finalParser)
                    }
                    else if let nextIndex = try consumeStructure(Structure.ValueSeparator, input: nextIndex) {
                        index = nextIndex
                        continue
                    }
                    else {
                        return nil
                    }
                }
                return nil
            }
        }
        
        func parseObjectMember(_ input: Index) throws -> (String, JSON, Index)? {
            guard let (name, index) = try parseString(input) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Missing object key at location \(source.distanceFromStart(input))"
                    ])
            }
            guard let separatorIndex = try consumeStructure(Structure.NameSeparator, input: index) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Invalid separator at location \(source.distanceFromStart(index))"
                    ])
            }
            guard let (value, finalIndex) = try parseValue(separatorIndex) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Invalid value at location \(source.distanceFromStart(separatorIndex))"
                    ])
            }
            
            return (name, value, finalIndex)
        }
        
        //MARK: - Array parsing
        func parseArray(_ input: Index) throws -> ([JSON], Index)? {
            guard let beginIndex = try consumeStructure(Structure.BeginArray, input: input) else {
                return nil
            }
            var index = beginIndex
            var output: [JSON] = []
            while true {
                if let finalIndex = try consumeStructure(Structure.EndArray, input: index) {
                    return (output, finalIndex)
                }
                
                if let (value, nextIndex) = try parseValue(index) {
                    output.append(value)
                    
                    if let finalIndex = try consumeStructure(Structure.EndArray, input: nextIndex) {
                        return (output, finalIndex)
                    }
                    else if let nextIndex = try consumeStructure(Structure.ValueSeparator, input: nextIndex) {
                        index = nextIndex
                        continue
                    }
                }
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Badly formed array at location \(source.distanceFromStart(index))"
                    ])
            }
        }
    }
}
