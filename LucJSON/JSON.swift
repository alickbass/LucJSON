//
//  JSON.swift
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

public enum JSON {
    case null
    case number(NSNumber)
    case bool(Bool)
    case string(String)
    case object([String: JSON])
    case array([JSON])
}

extension JSON: Equatable {
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case let (.number(left), .number(right)):
            return left == right
        case let (.bool(left), .bool(right)):
            return left == right
        case let (.string(left), .string(right)):
            return left == right
        case let (.object(left), .object(right)):
            return left == right
        case let (.array(left), .array(right)):
            return left == right
        default:
            return false
        }
    }
}

public extension JSON {
    public var isNull: Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }
    
    public var number: NSNumber? {
        switch self {
        case let .number(value): return value
        default: return nil
        }
    }
    
    public var bool: Bool? {
        switch self {
        case let .bool(value): return value
        default: return nil
        }
    }
    
    public var string: String? {
        switch self {
        case let .string(value): return value
        default: return nil
        }
    }
    
    public var object: [String: JSON]? {
        switch self {
        case let .object(value): return value
        default: return nil
        }
    }
    
    public var array: [JSON]? {
        switch self {
        case let .array(value): return value
        default: return nil
        }
    }
}
