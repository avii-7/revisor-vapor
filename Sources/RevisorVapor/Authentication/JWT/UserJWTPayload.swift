//
//  UserJWTPayload.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import JWT

struct UserJWTPayload: JWTPayload {
    
    let issuer = IssuerClaim(value: "revisor")
    
    let expiration = ExpirationClaim(value: .distantFuture)
    
    let subject: SubjectClaim
    
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case expiration = "exp"
        case subject = "sub"
    }
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self .expiration.verifyNotExpired()
    }
}
