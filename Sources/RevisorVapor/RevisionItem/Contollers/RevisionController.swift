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
            req.logger.error("Failed to fetch due revision items error=\(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
    }
    
    private func submitReview(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemID = UUID(uuidString: itemIdString) else {
            req.logger.error("Item ID is not valid - \(itemIdString)")
            throw Abort(.badRequest, reason: "Item ID is not valid")
        }

        do {
            let dto = try req.content.decode(RevisionItemSubmitRatingDTO.self)
            try await service.review(itemID: itemID, rating: dto.rating, userID: userId)
            req.logger.info("Review submission success - itemID=\(itemID) - rating=\(dto.rating)")
            return Response()
        }
        catch {
            req.logger.error("Review submission failed- \(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
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
            req.logger.error("Failed to fetch all revision items- \(error.localizedDescription)")
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
            req.logger.error("Failed to fetch preview items- \(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
    }
    
    private func createItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        do {
            let itemDTO = try req.content.decode(RevisionItemCreateRequestDTO.self)
            let createdItem = try await service.create(itemDTO, userID: userId)
            req.logger.info("Item created with id: \(createdItem.id)")
            
            let response = Response(status: .created)
            try response.content.encode(createdItem)
            return response
        }
        catch {
            req.logger.error("Failed to create item- \(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
    }
    
    private func item(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest, reason: "Invalid item id")
        }
        
        guard let item = try await service.item(for: userId, itemID: itemId) else {
            throw Abort(.notFound, reason: "Item not found")
        }
        
        let response = Response()
        try response.content.encode(item)
        return response
    }
    
    private func updateItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userID = userAuthenticable.userId
        
        do {
            let itemDTO = try req.content.decode(RevisionItemPatchRequestDTO.self)
            let updateItemDTO = try await service.update(request: itemDTO, userID: userID)
            req.logger.info("Item updated: \(updateItemDTO.id.uuidString)")
            
            let response = Response()
            try response.content.encode(updateItemDTO)
            return response
        }
        catch {
            req.logger.error("Falied to update an item: \(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
    }
    
    private func deleteItem(_ req: Request) async throws -> Response {
        let userAuthenticable = try req.auth.require(UserAuthenticatable.self)
        let userId = userAuthenticable.userId
        
        let itemIdString = try req.parameters.require(ParameterConstants.id)
        
        guard let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest, reason: "Item id is not valid.")
        }
        
        do {
            try await service.delete(itemID: itemId, userID: userId)
            req.logger.info("Item with id: \(itemId) was deleted")
            return Response()
        }
        catch {
            req.logger.error("Falied to delete an item: \(error.localizedDescription)")
            return Response(status: .internalServerError)
        }
    }
}
