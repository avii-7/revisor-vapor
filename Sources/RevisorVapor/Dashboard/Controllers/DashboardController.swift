//
//  DashboardController.swift
//  RevisorVapor
//
//  Created by Arun on 04/06/26.
//

import Vapor

struct RevisionItemPreview: Content {
    
    let id: UUID
    
    let title: String
}


enum RevisionState: String, Content {
    case ready
    case completed
}

struct RevisionInfo: Content {
    
    let state: RevisionState
    
    let nextRevisionAt: Date?
    
    let nextItem: RevisionItemPreview?
    
    let dueItemCount: Int
}

struct DashboardDTO: Content {
    
    let profile: ProfileDTO
    
    let revisionInfo: RevisionInfo?
    
    let revisionStats: [RevisionStatDTO]
}

struct DashboardController: RouteCollection, Sendable {
    
    private let revisionService: RevisionService
    
    private let userRepository: any UserRepository
    
    init(revisionService: RevisionService, userRepository: any UserRepository) {
        self.revisionService = revisionService
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("dashboard", use: dashboard)
    }
    
    private func dashboard(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        
        let userID = userAuthenticable.userId
        
        let profile = try await getProfileDTO(using: userID)
        
        let info = try await revisionService.revisionInfo(for: userID)
        
        let stats = try await revisionService.revisionStats(for: userID)
        
        let dashboarDTO = DashboardDTO(profile: profile, revisionInfo: info, revisionStats: stats)

        let response = Response(status: .ok)
        try response.content.encode(dashboarDTO)
        return response
    }
    
    private func getProfileDTO(using userId: UUID) async throws -> ProfileDTO {
        guard let user = try await userRepository.user(id: userId) else {
            throw Abort(.notFound)
        }
        
        let profile = try ProfileDTO(user)
        return profile
    }
}
