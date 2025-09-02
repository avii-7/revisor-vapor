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
    
    let content: String
    
    let revisionCount: Int
    
    let difficulty: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case revisionCount = "revision_count"
        case difficulty
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.revisionCount, forKey: .revisionCount)
        try container.encode(self.difficulty, forKey: .difficulty)
    }
}

struct RevisionItemRequestDTO: Content {
    
    let title: String
    
    let content: String
    
    let revisionCount: Int
    
    let difficulty: String
}

struct RevisionItemPatchRequestDTO: Decodable {
    
    let id: UUID
    
    let title: String?
    
    let content: String?
    
    let revisionCount: Int?
    
    let difficulty: String? // TODO: - Try to update with enum
}
