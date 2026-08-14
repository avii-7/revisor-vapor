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

//struct UserAuthenticator: AsyncBearerAuthenticator {
//    
//    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
//        let payload = try await request.jwt.verify(as: UserJWTPayload.self)
//        let userIdString = payload.subject.value
//        
//        if let userId = UUID(uuidString: userIdString) {
//            request.auth.login(UserAuthenticatable(userId: userId))
//        }
//        else {
//            throw Abort(.unauthorized)
//        }
//    }
//}

struct UserAuthenticator: AsyncRequestAuthenticator {
    
    func authenticate(request: Request) async throws {
        
        guard let jwt = request.cookies[CookiesConstant.jwtToken]?.string else {
            return
        }
        
        do {
            let payload = try await request.jwt.verify(jwt, as: UserJWTPayload.self)
            
            guard let userID = UUID(uuidString: payload.subject.value) else {
                return
            }
            
            request.auth.login(UserAuthenticatable(userId: userID))
        } catch {
            // Invalid/expired token -> not authenticated.
            return
        }
    }
}
