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
    
    @ID
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String?
    
    @Field(key: "platform_url")
    var platformUrl: String?
    
    @Field(key: "key_intuition")
    var keyIntuition: String?
    
    @Field(key: "solution_code")
    var solutionCode: String?
    
    @Field(key: "revision_count")
    var revisionCount: Int
    
    @Field(key: "streak")
    var streak: Int
    
    @Enum(key: "difficulty_level")
    var diffilcultyLevel: DifficultyLevel
    
    @Field(key: "category_ids")
    var categoryIDs: [UUID]
    
    @Field(key: "tags_ids")
    var tagIDs: [UUID]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        userId: UUID,
        title: String,
        content: String? = nil,
        platformUrl: String? = nil,
        keyIntuition: String? = nil,
        solutionCode: String? = nil,
        revisionCount: Int = .zero,
        streak: Int = .zero,
        diffilcultyLevel: DifficultyLevel = .default,
        categoryIDs: [UUID] = [],
        tagIDs: [UUID] = []
    ) {
        self.userId = userId
        self.title = title
        self.content = content
        self.platformUrl = platformUrl
        self.keyIntuition = keyIntuition
        self.solutionCode = solutionCode
        self.revisionCount = revisionCount
        self.streak = streak
        self.diffilcultyLevel = diffilcultyLevel
        self.categoryIDs = categoryIDs
        self.tagIDs = tagIDs
    }
}

enum DifficultyLevel: String, Codable {
    
    case `default`, easy, medium, hard
    
    static var name: String { "difficulty_level" }
    
    init(from decoder: any Decoder) throws {
        let continer = try decoder.singleValueContainer()
        let value = try continer.decode(String.self)
        
        let lowerCasedValue = value.lowercased()
        
        if let level =  DifficultyLevel(rawValue: lowerCasedValue) {
            self = level
        }
        else {
            let message = "Invalid Difficulty Value: \(value)"
            let error = DecodingError.dataCorruptedError(in: continer, debugDescription: message)
            throw error
        }
    }
}
