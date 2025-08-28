//
//  ProfileController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 25/08/25.
//

import Vapor

struct ProfileDTO: Content {
    let userId: UUID
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
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
        let email = try req.content.decode(String.self)
        
        guard let user = try await userRepository.get(by: email) else {
            throw Abort(.notFound)
        }
        
        
        let profile = ProfileDTO(
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.profilePicture
        )
        
        let response = Response(status: .ok)
        try response.content.encode(profile)
        return response
    }
}
