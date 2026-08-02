//
//  RevisionController.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Vapor
import FSRS

final class RevisionController: RouteCollection, Sendable {
    
    private let service: RevisionService
    
    init(service: RevisionService) {
        self.service = service
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(["revision-items"])
        let itemID = PathComponent.parameter(ParameterConstants.id)
        
        group.get(use: allItems)
        group.get(itemID, use: item)
        group.get("preview", use: previewItems)
        group.post(use: createItem)
        group.patch(use: updateItem)
        group.delete(itemID, use: deleteItem)
        
        group.get("due", use: dueRevisionItems)
        group.post(itemID, "review", use: submitReview)
    }
    
    private func dueRevisionItems(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        do {
            let items = try await service.dueRevisionItems(for: userId)
            let response = Response()
            try response.content.encode(items)
            return response
        }
        catch {
            print(error)
            return Response(status: .internalServerError)
        }
    }
    
    private func submitReview(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemID = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest)
        }
        
        let dto = try req.content.decode(RevisionItemSubmitRatingDTO.self)

        try await service.review(itemID: itemID, rating: dto.rating, userID: userId)
        
        let response = Response()
        return response
    }
    
    private func allItems(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let pageDTO = try req.query.decode(PageRequestDTO.self)
        
        do {
            let paginated = try await service.revisionItems(for: userId, paginationRequest: pageDTO)
            let response = Response()
            try response.content.encode(paginated)
            return response
        }
        catch {
            print(error)
            return Response(status: .internalServerError)
        }
    }
    
    private func previewItems(_ req: Request) async throws -> Response {
        
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        do {
            let items: [PreviewRevisionItemResponseDTO] = try await service.previewRevisionItems(for: userId)
            let response = Response()
            try response.content.encode(items)
            return response
        }
        catch {
            print(error)
            return Response(status: .internalServerError)
        }
    }
    
    private func createItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemDTO = try req.content.decode(RevisionItemCreateRequestDTO.self)
        let createdItem = try await service.create(itemDTO, userID: userId)
        
        let response = Response(status: .created)
        try response.content.encode(createdItem)
        return response
    }
    
    private func item(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest)
        }
        
        guard let item = try await service.item(for: userId, itemID: itemId) else {
            throw Abort(.notFound)
        }
        
        let response = Response()
        try response.content.encode(item)
        return response
    }
    
    private func updateItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userID = userAuthenticable.userId
        
        let itemDTO = try req.content.decode(RevisionItemPatchRequestDTO.self)
        let updateItemDTO = try await service.update(item: itemDTO, userID: userID)

        let response = Response()
        try response.content.encode(updateItemDTO)
        return response
    }
    
    private func deleteItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest)
        }
        
        try await service.delete(itemID: itemId, userID: userId)
        
        let response = Response()
        return response
    }
}
