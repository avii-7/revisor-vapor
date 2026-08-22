//
//  RevisionRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Fluent

protocol RevisionRepository: Sendable {
    
    func firstDueRevisionItem(for userID: UUID) async throws -> RevisionItem?
    
    func nextRevisionItem(for userID: UUID) async throws -> RevisionItem?
    
    func hasRevisionItems(for userID: UUID) async throws -> Bool
    
    func dueRevisionItemCount(for userID: UUID) async throws -> Int
    
    func totalRevisionItemsCount(for userID: UUID) async throws -> Int
    
    func totalRevisionsCount(for userID: UUID) async throws -> Int?
    
    func dueRevisionItems(for userID: UUID) async throws -> [RevisionItem]
    
    func previewRevisionItems(for userID: UUID) async throws -> [RevisionItem]
    
    func revisionItems(for userID: UUID, request: PageRequest) async throws -> Page<RevisionItem>
    
    func get(itemID: UUID, for userId: UUID) async throws -> RevisionItem?
    
    func create(_ item: RevisionItem, for userID: UUID) async throws -> RevisionItem
    
    @discardableResult
    func update(_ item: RevisionItem, for userID: UUID) async throws -> RevisionItem
    
    func save(_ item: RevisionItem) async throws 
    
    func delete(itemID: UUID, for userID: UUID) async throws
}

struct RevisionPostgresRepository: RevisionRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query(for userID: UUID) -> QueryBuilder<RevisionItem> {
        db.query(RevisionItem.self).filter(\.$userId == userID)
    }
    
    func firstDueRevisionItem(for userID: UUID) async throws -> RevisionItem? {
        let item = try await query(for: userID)
            .filter(\.$memoryState.$due <= Date.now)
            .sort(\.$memoryState.$due)
            .first()
        
        return item
    }
    
    func nextRevisionItem(for userID: UUID) async throws -> RevisionItem? {
        let item = try await query(for: userID)
            .sort(\.$memoryState.$due)
            .first()
        
        return item
    }
    
    func hasRevisionItems(for userID: UUID) async throws -> Bool {
        let exists = try await query(for: userID).first() != nil
        return exists
    }
    
    func dueRevisionItemCount(for userID: UUID) async throws -> Int {
        let count = try await query(for: userID)
            .filter(\.$memoryState.$due <= Date.now)
            .count()
        
        return count
    }
    
    func totalRevisionsCount(for userID: UUID) async throws -> Int? {
        let count = try await query(for: userID)
            .sum(\.$memoryState.$reps)
        
        return count
    }
    
    func dueRevisionItems(for userID: UUID) async throws -> [RevisionItem] {
        let items = try await query(for: userID)
            .filter(\.$memoryState.$due <= Date.now)
            .sort(\.$memoryState.$due)
            .all()
        
        return items
    }
    
    func totalRevisionItemsCount(for userID: UUID) async throws -> Int {
        let items = try await query(for: userID)
            .count()

        return items
    }
    
    func previewRevisionItems(for userID: UUID) async throws -> [RevisionItem] {
        let items = try await query(for: userID)
            .sort(\.$updatedAt, .descending)
            .limit(DBConstants.revisionItemsPreviewCount)
            .all()
        
        return items
    }
    
    func revisionItems(for userID: UUID, request: PageRequest) async throws -> Page<RevisionItem> {
        let result = try await query(for: userID)
            .sort(\.$updatedAt, .descending)
            .paginate(request)
            
        return result
    }
    
    func get(itemID: UUID, for userId: UUID) async throws -> RevisionItem? {
        let item = try await query(for: userId)
            .filter(\.$id == itemID)
            .first()
        
        return item
    }
    
    func create(_ item: RevisionItem, for userID: UUID) async throws -> RevisionItem {
        try await item.create(on: db)
        return item
    }
    
    func update(_ item: RevisionItem, for userID: UUID) async throws -> RevisionItem {
        
        guard let itemID = item.id else {
            throw FluentError.idRequired
        }
        
        if let existingItem = try await self.get(itemID: itemID, for: userID) {
            
            existingItem.title = item.title
            existingItem.content = item.content
            existingItem.platformUrl = item.platformUrl
            existingItem.keyIntuition = item.keyIntuition
            existingItem.solutionCode = item.solutionCode
            existingItem.tagIDs = item.tagIDs
            
            // Use save method to update MemoryState.
            // existingItem.memoryState = item.memoryState
            
            try await existingItem.update(on: db)
            return existingItem
        }
        else {
            try await item.update(on: db)
            return item
        }
    }
    
    func save(_ item: RevisionItem) async throws {
        try await item.save(on: db)
    }
    
    func delete(itemID: UUID, for userID: UUID) async throws {
        if let item = try await self.get(itemID: itemID, for: userID) {
            try await item.delete(on: db)
        }
        else {
            throw FluentError.noResults
        }
    }
}
