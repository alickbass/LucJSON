//
//  JSONWriter.swift
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
    struct Writer {
        
        var indent = 0
        let pretty: Bool
        let writer: (String?) -> Void
        
        private lazy var _numberformatter: CFNumberFormatter = {
            let formatter: CFNumberFormatter
            formatter = CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(), .noStyle)
            CFNumberFormatterSetProperty(formatter, .maxFractionDigits, NSNumber(value: 15))
            CFNumberFormatterSetFormat(formatter, "0.###############" as CFString)
            return formatter
        }()
        
        init(pretty: Bool = false, writer: @escaping (String?) -> Void) {
            self.pretty = pretty
            self.writer = writer
        }
        
        mutating func serializeJSON(_ json: JSON) throws {
            switch json {
            case .string(let str):
                try serializeString(str)
            case .bool(let boolValue):
                serializeBool(boolValue)
            case .array(let array):
                try serializeArray(array)
            case .object(let dict):
                try serializeDictionary(dict)
            case .null:
                try serializeNull()
            case .number(let number):
                try serializeNumber(number)
            }
        }
        
        func serializeString(_ str: String) throws {
            writer("\"")
            for scalar in str.unicodeScalars {
                switch scalar {
                case "\"":
                    writer("\\\"") // U+0022 quotation mark
                case "\\":
                    writer("\\\\") // U+005C reverse solidus
                // U+002F solidus not escaped
                case "\u{8}":
                    writer("\\b") // U+0008 backspace
                case "\u{c}":
                    writer("\\f") // U+000C form feed
                case "\n":
                    writer("\\n") // U+000A line feed
                case "\r":
                    writer("\\r") // U+000D carriage return
                case "\t":
                    writer("\\t") // U+0009 tab
                case "\u{0}"..."\u{f}":
                    writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
                case "\u{10}"..."\u{1f}":
                    writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
                default:
                    writer(String(scalar))
                }
            }
            writer("\"")
        }
        
        func serializeBool(_ bool: Bool) {
            switch bool {
            case true:
                writer("true")
            case false:
                writer("false")
            }
        }
        
        mutating func serializeNumber(_ num: NSNumber) throws {
            if num.doubleValue.isInfinite || num.doubleValue.isNaN {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: ["NSDebugDescription" : "Number cannot be infinity or NaN"])
            }
            
            writer(_serializationString(for: num))
        }
        
        mutating func serializeArray(_ array: [JSON]) throws {
            writer("[")
            if pretty {
                writer("\n")
                incAndWriteIndent()
            }
            
            var first = true
            for elem in array {
                if first {
                    first = false
                } else if pretty {
                    writer(",\n")
                    writeIndent()
                } else {
                    writer(",")
                }
                try serializeJSON(elem)
            }
            if pretty {
                writer("\n")
                decAndWriteIndent()
            }
            writer("]")
        }
        
        mutating func serializeDictionary(_ dict: Dictionary<String, JSON>) throws {
            writer("{")
            if pretty {
                writer("\n")
                incAndWriteIndent()
            }
            
            var first = true
            
            for (key, value) in dict {
                if first {
                    first = false
                } else if pretty {
                    writer(",\n")
                    writeIndent()
                } else {
                    writer(",")
                }
                
                
                try serializeString(key)
                pretty ? writer(": ") : writer(":")
                try serializeJSON(value)
            }
            if pretty {
                writer("\n")
                decAndWriteIndent()
            }
            writer("}")
        }
        
        func serializeNull() throws {
            writer("null")
        }
        
        let indentAmount = 2
        
        mutating func incAndWriteIndent() {
            indent += indentAmount
            writeIndent()
        }
        
        mutating func decAndWriteIndent() {
            indent -= indentAmount
            writeIndent()
        }
        
        func writeIndent() {
            for _ in 0..<indent {
                writer(" ")
            }
        }
        
        //[SR-2151] https://bugs.swift.org/browse/SR-2151
        private mutating func _serializationString(for number: NSNumber) -> String {
            return CFNumberFormatterCreateStringWithNumber(nil, _numberformatter, unsafeBitCast(number, to: CFNumber.self)) as String
        }
    }
}
