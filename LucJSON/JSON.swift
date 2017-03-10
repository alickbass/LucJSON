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
