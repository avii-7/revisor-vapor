//
//  UserAuthenticator.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor

final class UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(as: UserPayload.self)
        let email = payload.subject.value
        try request.content.encode(email)
    }
}
