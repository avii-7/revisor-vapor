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
}

struct RevisionItemRequestDTO: Content {
    
    let title: String
    
    let content: String
    
    let revisionCount: Int
    
    let difficulty: String
}

struct RevisionItemPatchRequestDTO: Decodable {
    
    let itemId: UUID
    
    let title: String?
    
    let content: String?
    
    let revisionCount: Int?
    
    let difficulty: String? // TODO: - Try to update with enum
}
