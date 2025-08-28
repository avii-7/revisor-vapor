//
//  RevisionItemsController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor

final class RevisionItemsController: RouteCollection, Sendable {
    
    private let repository: any RevisionItemsRepository
    
    init(repository: any RevisionItemsRepository) {
        self.repository = repository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("revise-items/:userId", use: getAllItems)
    }
    
    private func getAllItems(_ req: Request) async throws -> Response {
        let userIdString = try req.parameters.require("userId")
                
        guard let userId = UUID(uuidString: userIdString) else {
            throw Abort(.badRequest)
        }

        let items = try await repository.getAll(for: userId)
        
        let response = Response()
        try response.content.encode(items)
        return response
    }
    
    private func createItem(_ req: Request) async throws -> Response {
        let userIdString = try req.parameters.require("userId")
        let itemDTO = try req.content.decode(RevisionItemRequestDTO.self)
        
        guard let userId = UUID(uuidString: userIdString) else {
            throw Abort(.badRequest)
        }

        try await repository.create(itemDTO, for: userId)
        
        let response = Response()
        return response
    }
}
