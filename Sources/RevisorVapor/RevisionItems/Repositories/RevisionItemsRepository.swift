//
//  RevisionItemsRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Fluent

protocol RevisionItemsRepository: Sendable {
    
    func getAll(for userId: UUID) async throws -> [RevisionItemResponseDTO]
    
    func create(_ dto: RevisionItemRequestDTO, for userId: UUID) async throws
}

final class RevisionItemsPostgresRepository: RevisionItemsRepository {
    
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
}
