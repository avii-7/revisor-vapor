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
            .field("last_name", .string)
            .field("email", .string, .required)
            .field("profile_picture", .string)
            .field("token_access_token", .string, .required)
            .field("token_refresh_token", .string, .required)
            .field("token_expires_in", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
