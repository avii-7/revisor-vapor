//
//  RevisionItemRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Fluent

protocol RevisionItemRepository: Sendable {
    
    func getAll(for userId: UUID) async throws -> [RevisionItemResponseDTO]
    
    func create(_ dto: RevisionItemRequestDTO, for userId: UUID) async throws
    
    func update(_ dto: RevisionItemPatchRequestDTO, for userId: UUID) async throws
}

final class RevisionItemPostgresRepository: RevisionItemRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query() -> QueryBuilder<RevisionItem> {
        db.query(RevisionItem.self)
    }
    
    func getAll(for userId: UUID) async throws -> [RevisionItemResponseDTO] {
        let items = try await query().filter(\.$userId == userId).all()
        let dtos = items.map { RevisionItemMapper.map($0) }
        return dtos
    }
    
    func create(_ dto: RevisionItemRequestDTO, for userId: UUID) async throws {
        let item = RevisionItemMapper.map(dto, userId: userId)
        try await item.create(on: db)
    }
    
    func update(_ dto: RevisionItemPatchRequestDTO, for userId: UUID) async throws {
        
        guard let dbItem = try await query()
            .filter(\.$userId == userId)
            .filter(\.$id == dto.itemId)
            .first() else {
            // TODO: - Throw error if not found
            return
        }

        if let title = dto.title, title.isEmpty == false {
            dbItem.title = title
        }
        
        if let content = dto.content, content.isEmpty == false {
            dbItem.content = content
        }
        
        if let revisionCount = dto.revisionCount {
            dbItem.revisionCount = revisionCount
        }
        
        if let difficultyLevel = dto.difficulty {
            dbItem.diffilcultyLevel = DifficultyLevel(rawValue: difficultyLevel) ?? .default
        }
        
        try await dbItem.update(on: db)
    }
}
