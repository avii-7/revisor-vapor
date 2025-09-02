//
//  RevisionItemController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor

final class RevisionItemController: RouteCollection, Sendable {
    
    private let repository: any RevisionItemRepository
    
    init(repository: any RevisionItemRepository) {
        self.repository = repository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("revise-items", use: getAllItems)
        routes.post("revise-items", use: createItem)
        routes.patch("revise-items", use: updateCount)
    }
    
    private func getAllItems(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId

        let items: [RevisionItemResponseDTO] = try await repository.getAll(for: userId)
        
        let response = Response()
        try response.content.encode(items)
        return response
    }
    
    private func createItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemDTO = try req.content.decode(RevisionItemRequestDTO.self)

        try await repository.create(itemDTO, for: userId)
        
        let response = Response(status: .created)
        return response
    }
    
    private func updateCount(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemDTO = try req.content.decode(RevisionItemPatchRequestDTO.self)
        
        try await repository.update(itemDTO, for: userId)
        
        let response = Response(status: .accepted)
        return response
    }
}
