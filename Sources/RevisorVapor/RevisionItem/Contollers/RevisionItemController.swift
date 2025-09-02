//
//  RevisionItemController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor

extension RevisionItemController {
    
    enum Endpoint: String {
        case reviseItems = "revise-items"
    }
}

final class RevisionItemController: RouteCollection, Sendable {
    
    private let repository: any RevisionItemRepository
    
    init(repository: any RevisionItemRepository) {
        self.repository = repository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        
        let endpoint = PathComponent(stringLiteral: Endpoint.reviseItems.rawValue)
        routes.get(endpoint, use: getAllItems)
        routes.post(endpoint, use: createItem)
        routes.patch(endpoint, use: updateItem)
        routes.delete(endpoint, ":itemId", use: deleteItem)
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
    
    private func updateItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemDTO = try req.content.decode(RevisionItemPatchRequestDTO.self)
        
        try await repository.update(itemDTO, for: userId)
        
        let response = Response()
        return response
    }
    
    private func deleteItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require("itemId")
        guard let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest)
        }
        
        try await repository.delete(itemId: itemId, for: userId)
        
        let response = Response()
        return response
    }
}
