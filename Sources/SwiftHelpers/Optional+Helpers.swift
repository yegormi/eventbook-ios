//
//  File.swift
//  eventbook-ios
//
//  Created by Yehor Myropoltsev on 18.04.2025.
//

import Foundation

public extension Optional {
    var isNil: Bool { self == nil }
    var isNotNil: Bool { isNil.negation }
}

public extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}

public extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}
