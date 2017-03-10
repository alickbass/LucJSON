//
//  JSONSerialization.swift
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
    /** A type for converting JSON data to JSON objects and converting JSON objects to JSON data.
     
     An object that may be converted to JSON must have the following properties:
     - Top level object is a `Swift.Array` or `Swift.Dictionary`
     - All dictionary keys are `Swift.String`s
     - `NSNumber`s are not NaN or infinity
     */
    public struct Serialization {
        public struct ReadingOptions : OptionSet {
            public let rawValue : UInt
            public init(rawValue: UInt) { self.rawValue = rawValue }
            
            public static let allowFragments = ReadingOptions(rawValue: 1 << 0)
        }
        
        public struct WritingOptions : OptionSet {
            public let rawValue : UInt
            public init(rawValue: UInt) { self.rawValue = rawValue }
            
            public static let prettyPrinted = WritingOptions(rawValue: 1 << 0)
        }
        
        /* Generate JSON data from a JSON object. If the object will not produce valid JSON then an exception will be thrown. Setting the WritingOptions.prettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. The resulting data is a encoded in UTF-8.
         */
        static func _data(withJSON value: JSON, options opt: WritingOptions, stream: Bool) throws -> Data {
            var jsonStr = String()
            
            var writer = Writer(
                pretty: opt.contains(.prettyPrinted),
                writer: { (str: String?) in
                    if let str = str {
                        jsonStr.append(str)
                    }
            }
            )
            
            try writer.serializeJSON(value)
            let count = jsonStr.lengthOfBytes(using: .utf8)
            let bufferLength = count+1 // Allow space for null terminator
            var utf8: [CChar] = Array<CChar>(repeating: 0, count: bufferLength)
            if !jsonStr.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
                fatalError("Failed to generate a CString from a String")
            }
            let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
            let result = Data(bytes: rawBytes.bindMemory(to: UInt8.self, capacity: count), count: count)
            return result
        }
        
        public static func data(withJSON value: JSON, options opt: WritingOptions = []) throws -> Data {
            return try _data(withJSON: value, options: opt, stream: false)
        }
        
        /* Create a JSON object from JSON data. Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an Array or Dictionary. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
         The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
         */
        public static func jsonObject(with data: Data, options opt: ReadingOptions = []) throws -> JSON {
            return try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> JSON in
                let encoding: String.Encoding
                let buffer: UnsafeBufferPointer<UInt8>
                if let detected = parseBOM(bytes, length: data.count) {
                    encoding = detected.encoding
                    buffer = UnsafeBufferPointer(start: bytes.advanced(by: detected.skipLength), count: data.count - detected.skipLength)
                }
                else {
                    encoding = detectEncoding(bytes, data.count)
                    buffer = UnsafeBufferPointer(start: bytes, count: data.count)
                }
                
                let source = Reader.UnicodeSource(buffer: buffer, encoding: encoding)
                let reader = Reader(source: source)
                if let (object, _) = try reader.parseObject(0) {
                    return .object(object)
                }
                else if let (array, _) = try reader.parseArray(0) {
                    return .array(array)
                }
                else if opt.contains(.allowFragments), let (value, _) = try reader.parseValue(0) {
                    return value
                }
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "JSON text did not start with array or object and option to allow fragments not set."
                    ])
            }
        }
        
        /* Write JSON data into a stream. The stream should be opened and configured. The return value is the number of bytes written to the stream, or 0 on error. All other behavior of this method is the same as the dataWithJSONObject:options:error: method.
         */
        public static func writeJSON(_ json: JSON, toStream stream: OutputStream, options opt: WritingOptions) throws -> Int {
            let jsonData = try _data(withJSON: json, options: opt, stream: true)
            let count = jsonData.count
            return jsonData.withUnsafeBytes { (bytePtr: UnsafePointer<UInt8>) -> Int in
                let res: Int = stream.write(bytePtr, maxLength: count)
                /// TODO: If the result here is negative the error should be obtained from the stream to propigate as a throw
                return res
            }
        }
        
        /* Create a JSON object from JSON data stream. The stream should be opened and configured. All other behavior of this method is the same as the JSONObjectWithData:options:error: method.
         */
        public static func jsonObject(with stream: InputStream, options opt: ReadingOptions = []) throws -> JSON {
            var data = Data()
            guard stream.streamStatus == .open || stream.streamStatus == .reading else {
                fatalError("Stream is not available for reading")
            }
            repeat {
                var buffer = [UInt8](repeating: 0, count: 1024)
                var bytesRead: Int = 0
                bytesRead = stream.read(&buffer, maxLength: buffer.count)
                if bytesRead < 0 {
                    throw stream.streamError!
                } else {
                    data.append(&buffer, count: bytesRead)
                }
            } while stream.hasBytesAvailable
            return try jsonObject(with: data, options: opt)
        }
    }
}

//MARK: - Encoding Detection
internal extension JSON.Serialization {
    
    /// Detect the encoding format of the NSData contents
    static func detectEncoding(_ bytes: UnsafePointer<UInt8>, _ length: Int) -> String.Encoding {
        
        if length >= 4 {
            switch (bytes[0], bytes[1], bytes[2], bytes[3]) {
            case (0, 0, 0, _):
                return .utf32BigEndian
            case (_, 0, 0, 0):
                return .utf32LittleEndian
            case (0, _, 0, _):
                return .utf16BigEndian
            case (_, 0, _, 0):
                return .utf16LittleEndian
            default:
                break
            }
        }
        else if length >= 2 {
            switch (bytes[0], bytes[1]) {
            case (0, _):
                return .utf16BigEndian
            case (_, 0):
                return .utf16LittleEndian
            default:
                break
            }
        }
        return .utf8
    }
    
    static func parseBOM(_ bytes: UnsafePointer<UInt8>, length: Int) -> (encoding: String.Encoding, skipLength: Int)? {
        if length >= 2 {
            switch (bytes[0], bytes[1]) {
            case (0xEF, 0xBB):
                if length >= 3 && bytes[2] == 0xBF {
                    return (.utf8, 3)
                }
            case (0x00, 0x00):
                if length >= 4 && bytes[2] == 0xFE && bytes[3] == 0xFF {
                    return (.utf32BigEndian, 4)
                }
            case (0xFF, 0xFE):
                if length >= 4 && bytes[2] == 0 && bytes[3] == 0 {
                    return (.utf32LittleEndian, 4)
                }
                return (.utf16LittleEndian, 2)
            case (0xFE, 0xFF):
                return (.utf16BigEndian, 2)
            default:
                break
            }
        }
        return nil
    }
}
