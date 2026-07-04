//
//  RevisionItemDTO.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Vapor

struct NextRevision: Content {
    
    let easy: Date
    
    let good: Date
    
    let hard: Date
    
    let again: Date
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
    
    let lastReview: Date?
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
}
