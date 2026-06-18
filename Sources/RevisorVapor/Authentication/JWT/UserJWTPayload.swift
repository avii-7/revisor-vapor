//
//  UserJWTPayload.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import JWT
import Vapor

extension IssuerClaim {
    static let revisor = Self(value: "revisor")
}

struct UserJWTPayload: JWTPayload {
    
    let issuer: IssuerClaim = .revisor
    
    let expiration = ExpirationClaim(value: .now.addingTimeInterval(3600))
    
    let subject: SubjectClaim
    
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case expiration = "exp"
        case subject = "sub"
    }
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self .expiration.verifyNotExpired()
        
        guard issuer == .revisor else {
            throw Abort(.unauthorized)
        }
    }
}
