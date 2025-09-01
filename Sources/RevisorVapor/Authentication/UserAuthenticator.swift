//
//  UserAuthenticator.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor

struct UserAuthenticatable: Authenticatable {
    let userId: UUID
}

struct UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(as: UserPayload.self)
        let userIdString = payload.subject.value
        
        if let userId = UUID(uuidString: userIdString) {
            request.auth.login(UserAuthenticatable(userId: userId))
        }
        else {
            throw Abort(.unauthorized)
        }
    }
}
