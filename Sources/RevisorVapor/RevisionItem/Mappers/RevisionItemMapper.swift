//
//  RevisionItemMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation

struct RevisionItemMapper {
    
    private init() { }
    
    static func map(_ revisionItem: RevisionItem) -> RevisionItemResponseDTO {
        RevisionItemResponseDTO(
            id: revisionItem.id!,
            title: revisionItem.title,
            content: revisionItem.content,
            revisionCount: revisionItem.revisionCount,
            difficulty: revisionItem.diffilcultyLevel.rawValue
        )
    }
    
    static func map(_ dto: RevisionItemRequestDTO, userId: UUID) -> RevisionItem {
        RevisionItem(
            userId: userId,
            title: dto.title,
            content: dto.content,
            diffilcultyLevel: DifficultyLevel(rawValue: dto.difficulty)
        )
    }
}
