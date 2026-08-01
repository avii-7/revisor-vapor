//
//  RevisionMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import FluentKit

struct RevisionMapper {
    
    private init() { }

    static func map(_ item: RevisionItem, nextRevision: NextRevision?) -> RevisionItemResponseDTO {
        RevisionItemResponseDTO(
            id: item.id!,
            title: item.title,
            content: item.content,
            platformUrl: item.platformUrl,
            keyIntuition:  item.keyIntuition,
            solutionCode: item.solutionCode,
            nextRevision: nextRevision,
            due: item.memoryState.due,
            totalRevisionCount: item.memoryState.reps,
            lastReview: item.memoryState.lastReview,
            tags: item.tagIDs?.map { TagDTO(id: $0, name: "Dummy") },
            folder: nil
        )
    }
    
    static func map(_ item: RevisionItem) -> PreviewRevisionItemResponseDTO {
        PreviewRevisionItemResponseDTO(
            id: item.id!,
            title: item.title,
            subtitle: nil,
            revisionCount: item.memoryState.reps,
            lastReview: item.memoryState.lastReview,
            tags: item.tagIDs?.map { TagDTO(id: $0, name: "Dummy") },
            folder: nil
        )
    }
    
    static func map(_ dto: RevisionItemCreateRequestDTO, userID: UUID) -> RevisionItem {
        RevisionItem(
            userId: userID,
            title: dto.title,
            content: dto.content,
            platformUrl: dto.platformUrl,
            keyIntuition: dto.keyIntuition,
            solutionCode: dto.solutionCode
        )
    }
    
    static func map(_ dto: RevisionItemPatchRequestDTO, userID: UUID) -> RevisionItem {
        RevisionItem(
            userId: userID,
            title: dto.title,
            content: dto.content,
            platformUrl: dto.platformUrl,
            keyIntuition: dto.keyIntuition,
            solutionCode: dto.solutionCode
        )
    }
    
    static func map(_ dbModel: Page<RevisionItem>) -> PaginatedDTO<RevisionItemResponseDTO> {
        PaginationMapper.map(dbModel) { Self.map($0, nextRevision: nil) }
    }
    
    static func map(_ dbModel: Page<RevisionItem>) -> PaginatedDTO<PreviewRevisionItemResponseDTO> {
        PaginationMapper.map(dbModel) { Self.map($0) }
    }
}
