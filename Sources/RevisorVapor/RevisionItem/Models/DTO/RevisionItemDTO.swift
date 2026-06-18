//
//  RevisionItemDTO.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Vapor

struct RevisionItemResponseDTO: Content {
    
    let id: UUID
    
    let title: String
    
    let subtitle: String
    
    let streak: Int
    
    let content: String?
    
    let revisionCount: Int
    
    let difficulty: DifficultyLevel
}

struct RevisionItemCreateRequestDTO: Content {
    
    let title: String
    
    let content: String?
    
    let difficulty: DifficultyLevel
    
    let platformUrl: String?
    
    let keyIntuition: String?
    
    let solutionCode: String?
    
    enum CodingKeys: String, CodingKey {
        case title, content, difficulty
        case platformUrl = "platform_url"
        case keyIntuition = "key_intuition"
        case solutionCode = "solution_code"
    }
}

struct RevisionItemPatchRequestDTO: Decodable {
    
    let id: UUID
    
    let title: String?
    
    let content: String?
    
    let revisionCount: Int?
    
    let difficulty: DifficultyLevel? // TODO: - Try to update with enum
}
