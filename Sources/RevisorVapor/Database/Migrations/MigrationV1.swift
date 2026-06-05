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
            .field("settings_retention_rate", .double, .required)
            .field("token_access_token", .string, .required)
            .field("token_refresh_token", .string, .required)
            .field("token_expires_in", .int, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .create()
        
        try await database.schema(RevisionItemCategory.schema)
            .id()
            .field("user_id", .uuid)
            .field("title", .string, .required)
            .field("isPredefined", .bool, .required)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        try await database.schema(RevisionItemTag.schema)
            .id()
            .field("user_id", .uuid)
            .field("title", .string, .required)
            .field("isPredefined", .bool, .required)
            .foreignKey("user_id", references: User.schema, "id")
            .create()
        
        try await database.schema(RevisionItem.schema)
            .id()
            .field("user_id", .uuid, .required)
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("revision_count", .int, .required)
            .field("streak", .int, .required)
            .field("category_ids", .array(of: .uuid), .required)
            .field("tags_ids", .array(of: .uuid), .required)
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
            .field(.init(stringLiteral: DifficultyLevel.name), difficultyLevel, .required)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        
        try await database.schema(RevisionItemCategory.schema).delete()
        try await database.schema(RevisionItemTag.schema).delete()

        try await database.schema(RevisionItem.schema).delete()
        try await database.enum(DifficultyLevel.name).delete()
        
        try await database.schema(User.schema).delete()
    }
}
