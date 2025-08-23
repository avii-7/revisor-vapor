//
//  GoogleToken.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

import Fluent
import Foundation

final class GoogleToken: Fields, @unchecked Sendable {
    
    @Field(key: "access_token")
    var accessToken: String
    
    @Field(key: "refresh_token")
    var refreshToken: String
    
    @Field(key: "expires_in")
    var expiresIn: Int
    
    init() { }
    
    init(accessToken: String, refreshToken: String, expiresIn: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}
