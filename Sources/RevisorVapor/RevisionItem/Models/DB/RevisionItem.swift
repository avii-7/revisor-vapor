//
//  RevisionItem.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 28/08/25.
//

import Foundation
import Fluent

typealias RevisionCardState = MemoryState.CardState

final class MemoryState: Fields, @unchecked Sendable {
    
    enum CardState: String, Codable {
        
        static var name: String { "card_state" }
        
        case new
        case learning
        case review
        case relearning
    }
    
    // The next scheduled review date.
    @Field(key: "due")
    var due: Date
    
    // How long the memory is expected to last before forgetting. Higher means the interval grows faster.
    @Field(key: "stability")
    var stability: Double
    
    @Field(key: "difficulty")
    var difficulty: Double
    
    // Total number of reviews completed.
    @Field(key: "reps")
    var reps: Int
    
    // Number of times the item was forgotten (Again).
    @Field(key: "lapses")
    var lapses: Int
    
    @Enum(key: "state")
    var state: CardState
    
    // Timestamp of the previous review.
    @Field(key: "last_review")
    var lastReview: Date?
    
    init() {
        self.due = .now
        self.stability = .zero
        self.difficulty = .zero
        self.reps = .zero
        self.lapses = .zero
        self.state = .new
        self.lastReview = nil
    }
    
    init(
        due: Date = .now,
        stability: Double = .zero,
        difficulty: Double = .zero,
        reps: Int = .zero,
        lapses: Int = .zero,
        state: CardState = .new,
        lastReview: Date? = nil
    ) {
        self.due = due
        self.stability = stability
        self.difficulty = difficulty
        self.reps = reps
        self.lapses = lapses
        self.state = state
        self.lastReview = lastReview
    }
}

final class RevisionItem: Model, @unchecked Sendable {
    
    static let schema = "revision_items"
    
    @ID
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "title")
    var title: String
    
    @OptionalField(key: "content")
    var content: String?
    
    @OptionalField(key: "platform_url")
    var platformUrl: String?
    
    @OptionalField(key: "key_intuition")
    var keyIntuition: String?
    
    @OptionalField(key: "solution_code")
    var solutionCode: String?
    
    @Group(key: "memory_state")
    var memoryState: MemoryState
    
    @Field(key: "tags_ids")
    var tagIDs: [UUID]?
    
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
        memoryState: MemoryState = MemoryState(),
        tagIDs: [UUID]? = nil
    ) {
        self.userId = userId
        self.title = title
        self.content = content
        self.platformUrl = platformUrl
        self.keyIntuition = keyIntuition
        self.solutionCode = solutionCode
        self.memoryState = memoryState
        self.tagIDs = tagIDs
    }
}

enum InputRating: String, Codable {
    
    case again, hard, good, easy
    
    static var name: String { "rating" }
}
