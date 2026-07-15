//
//  Token.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

import Fluent
import Foundation

final class Token: Fields, @unchecked Sendable {
    
    @Field(key: "hash")
    // refresh token for JWT
    var tokenHash: String
    
    @Field(key: "expires_in")
    var expiresIn: Date
    
    init() { }
    
    init(tokenHash: String, expiresIn: Date) {
        self.tokenHash = tokenHash
        self.expiresIn = expiresIn
    }
}
