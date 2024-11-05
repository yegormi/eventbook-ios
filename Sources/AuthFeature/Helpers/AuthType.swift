//
//  AuthType.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.11.2023.
//

import Foundation

enum AuthType {
    case signIn, signUp

    var title: String {
        switch self {
        case .signIn:
            return "Log in"
        case .signUp:
            return "Sign up"
        }
    }

    mutating func toggle() {
        self = (self == .signIn) ? .signUp : .signIn
    }
}
