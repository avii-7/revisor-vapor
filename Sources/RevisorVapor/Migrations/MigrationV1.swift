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
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("email", .string, .required)
            .field("profile_picture", .string)
            .field("token_access_token", .string, .required)
            .field("token_refresh_token", .string, .required)
            .field("token_expires_in", .int, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .create()
        
        try await database.schema(RevisionItem.schema)
            .id()
            .field("user_id", .uuid, .required)
            .field("title", .string, .required)
            .field("description", .string)
            .field("revisionCount", .int, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        let difficultyLevel = try await database.enum(DifficultyLevel.name)
            .case(DifficultyLevel.default.rawValue)
            .case(DifficultyLevel.easy.rawValue)
            .case(DifficultyLevel.medium.rawValue)
            .case(DifficultyLevel.hard.rawValue)
            .create()
        
        try await database.schema(RevisionItem.schema)
            .field("difficulty_level", difficultyLevel, .required)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
        try await database.enum(DifficultyLevel.name).delete()
        try await database.schema(RevisionItem.schema).delete()
    }
}
