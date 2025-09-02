//
//  RevisionItem.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Fluent

final class RevisionItem: Model, @unchecked Sendable {
    
    static let schema = "revision_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "revision_count")
    var revisionCount: Int
    
    @Enum(key: "difficulty_level")
    var diffilcultyLevel: DifficultyLevel
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(userId: UUID, title: String, content: String, revisionCount: Int, diffilcultyLevel: DifficultyLevel? = .default) {
        self.userId = userId
        self.title = title
        self.content = content
        self.revisionCount = revisionCount
        self.diffilcultyLevel = diffilcultyLevel ?? .default
    }
}

enum DifficultyLevel: String, Codable {
    case `default`, easy, medium, hard
    
    static var name: String { "difficulty_level" }
}
