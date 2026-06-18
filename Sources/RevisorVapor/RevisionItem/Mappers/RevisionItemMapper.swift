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
            subtitle: "Yet to be added",
            streak: 8,
            content: revisionItem.content,
            revisionCount: revisionItem.revisionCount,
            difficulty: revisionItem.diffilcultyLevel
        )
    }
    
    static func map(_ dto: RevisionItemCreateRequestDTO, userId: UUID) -> RevisionItem {
        RevisionItem(
            userId: userId,
            title: dto.title,
            content: dto.content,
            platformUrl: dto.platformUrl,
            keyIntuition: dto.keyIntuition,
            solutionCode: dto.solutionCode,
            diffilcultyLevel: dto.difficulty
        )
    }
}
