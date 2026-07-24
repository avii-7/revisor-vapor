//
//  MigrationV1.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

import FluentKit

struct MigrationV1: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("google_id", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("email", .string, .required)
            .field("profile_picture", .string)
            .field("settings_retention_rate", .double, .required)
            .field("token_hash", .string, .required)
            .field("token_expires_in", .datetime, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .unique(on: "token_hash")
            .unique(on: "google_id")
            .create()
        
        try await database.schema(RevisionItemCategory.schema)
            .id()
            .field("user_id", .uuid)
            .field("title", .string, .required)
            .field("is_predefined", .bool, .required)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        try await database.schema(RevisionItemTag.schema)
            .id()
            .field("user_id", .uuid)
            .field("title", .string, .required)
            .field("is_predefined", .bool, .required)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        try await database.schema(RevisionItem.schema)
            .id()
            .field("user_id", .uuid, .required)
            .field("title", .string, .required)
            .field("content", .string)
            .field("platform_url", .string)
            .field("key_intuition", .string)
            .field("solution_code", .string)
        
            .field("memory_state_due", .datetime, .required)
            .field("memory_state_stability", .double, .required)
            .field("memory_state_difficulty", .double, .required)
            .field("memory_state_reps", .int, .required)
            .field("memory_state_lapses", .int, .required)
        
            .field("memory_state_last_review", .datetime)
        
            .field("tags_ids", .array(of: .uuid))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        let cardStateType = try await database.enum(RevisionCardState.name)
            .case(RevisionCardState.new.rawValue)
            .case(RevisionCardState.learning.rawValue)
            .case(RevisionCardState.review.rawValue)
            .case(RevisionCardState.relearning.rawValue)
            .create()
        
        try await database.schema(RevisionItem.schema)
            .field("memory_state_state", cardStateType, .required)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        
        try await database.schema(RevisionItemCategory.schema).delete()
        
        try await database.schema(RevisionItemTag.schema).delete()

        try await database.schema(RevisionItem.schema).delete()
        
        try await database.enum(RevisionCardState.name).delete()
        
        try await database.schema(User.schema).delete()
    }
}
