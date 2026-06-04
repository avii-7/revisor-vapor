//
//  ProfileController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 25/08/25.
//

import Vapor

struct UserSettingsDTO: Content {
    let retentionRate: Double
}

extension UserSettingsDTO {
    
    init(_ settings: UserSettings) {
        self.init(
            retentionRate: settings.retentionRate
        )
    }
}

struct ProfileDTO: Content {
    let userId: UUID
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
    let userSettings: UserSettingsDTO
}

extension ProfileDTO {
    
    init(_ user: User) throws {
        self.init(
            userId: try user.requireID(),
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.profilePicture,
            userSettings: UserSettingsDTO(user.settings)
        )
    }
}

struct ProfileController: RouteCollection, Sendable {
    
    private let userRepository: any UserRepository
    
    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("profile", use: getProfile)
    }
    
    private func getProfile(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        
        let userId = userAuthenticable.userId
        
        guard let user = try await userRepository.get(by: userId) else {
            throw Abort(.notFound)
        }
        
        let profile = try ProfileDTO(user)
        
        let response = Response(status: .ok)
        try response.content.encode(profile)
        return response
    }
}
