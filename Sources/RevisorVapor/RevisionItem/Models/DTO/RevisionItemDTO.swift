//
//  RevisionItemDTO.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Vapor

struct TagDTO: Content {
    
    let id: UUID
    
    let name: String
}

struct FolderDTO: Content {
    
    let id: UUID
    
    let name: String
}

struct NextRevision: Content {
    
    let easy: Date
    
    let good: Date
    
    let hard: Date
    
    let again: Date
}

struct PreviewRevisionItemResponseDTO: Content {
    
    let id: UUID
    
    let title: String
    
    let subtitle: String?
    
    let revisionCount: Int
    
    let lastReview: Date?
    
    let tags: [TagDTO]?
    
    let folder: FolderDTO?
}

struct RevisionItemResponseDTO: Content {
    
    let id: UUID
    
    let title: String
    
    let content: String?
    
    let platformUrl: String?
    
    let keyIntuition: String?
    
    let solutionCode: String?
    
    let nextRevision: NextRevision?
    
    let due: Date
    
    let revisionCount: Int
    
    let lastReview: Date?
    
    let tags: [TagDTO]?
    
    let folder: FolderDTO?
}

struct RevisionItemCreateRequestDTO: Content {
    
    let title: String
    
    let content: String?
    
    let platformUrl: String?
    
    let keyIntuition: String?
    
    let solutionCode: String?
}

struct RevisionItemPatchRequestDTO: Decodable {
    
    let id: UUID
    
    let title: String
    
    let content: String?
    
    let platformUrl: String?
    
    let keyIntuition: String?
    
    let solutionCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content
        case platformUrl = "platform_url"
        case keyIntuition = "key_intuition"
        case solutionCode = "solution_code"
    }
}

struct RevisionItemSubmitRatingDTO: Content {
    let rating: InputRating
}
