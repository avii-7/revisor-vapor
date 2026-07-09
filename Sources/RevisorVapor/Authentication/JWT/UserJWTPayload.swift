//
//  UserJWTPayload.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import JWT
import Vapor

struct UserJWTPayload: JWTPayload {
    
    let issuer: IssuerClaim
    
    let subject: SubjectClaim
    
    let expiration: ExpirationClaim
    
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

extension ExpirationClaim {
    
    static var expireClaim: Self { Self(value: .now.addingTimeInterval(3600)) }
}

extension IssuerClaim {
    static let revisor = Self(value: "revisor")
}
