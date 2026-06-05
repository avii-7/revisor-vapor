//
//  DashboardController.swift
//  RevisorVapor
//
//  Created by Arun on 04/06/26.
//

import Vapor

struct RevisionStat: Content {
    
    let id: String
    
    let title: String
    
    let value: String
}

struct RevisionInfo: Content {
    
    let title: String
    
    let subtitle: String
    
    let ctaText: String
    
    let topText: String
}

struct DashboardDTO: Content {
    
    let profile: ProfileDTO
    
    let revisionInfo: RevisionInfo?
    
    let revisionStats: [RevisionStat]
}

struct DashboardController: RouteCollection, Sendable {
    
    private let userRepository: any UserRepository
    
    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("dashboard", use: getDashboard)
    }
    
    private func getDashboard(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        
        let userId = userAuthenticable.userId
        
        let profile = try await getProfileDTO(using: userId)
        
        // TODO: - needs to get first problem title.
        
        let info = RevisionInfo(
            title: "Median of Two Sorted Array",
            subtitle: "Scheduled for today. Estimated time: 15 minutes.",
            ctaText: "Start Revision",
            topText: "UP Next"
        )
        
        let stats = [
            RevisionStat(id: "total_problems", title: "Total Problems", value: "342"),
            RevisionStat(id: "total_revisions", title: "Total Revisions", value: "1208"),
            RevisionStat(id: "success_rate", title: "Success Rate", value: "94.2%")
        ]
        
        let dashboarDTO = DashboardDTO(profile: profile, revisionInfo: info, revisionStats: stats)

        let response = Response(status: .ok)
        try response.content.encode(dashboarDTO)
        return response
    }
    
    private func getProfileDTO(using userId: UUID) async throws -> ProfileDTO {
        guard let user = try await userRepository.get(by: userId) else {
            throw Abort(.notFound)
        }
        
        let profile = try ProfileDTO(user)
        return profile
    }
}
