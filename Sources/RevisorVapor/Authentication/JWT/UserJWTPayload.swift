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
            throw JWTError.claimVerificationFailure(failedClaim: issuer, reason: "Failed issuer claim")
        }
    }
}

extension ExpirationClaim {
    
    static var oneHour: Self { Self(value: .now.addingTimeInterval(3600)) }
}

extension IssuerClaim {
    static let revisor = Self(value: "revisor")
}
