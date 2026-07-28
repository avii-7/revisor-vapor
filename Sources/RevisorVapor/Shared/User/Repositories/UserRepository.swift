//
//  UserRepository.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Fluent
import Foundation

protocol UserRepository: Sendable {
    
    @discardableResult
    func createOrUpdate(_ userDTO: UserDTO) async throws -> User
    
    func user(id: UUID) async throws -> User?
    
    func user(hash: String) async throws -> User?
    
    func user(googleId: String) async throws -> User?
    
    func update(_ userDTO: UserDTO, with id: UUID) async throws -> User
    
    func update(user: User) async throws
}

struct UserPostgresRepository: UserRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query() -> QueryBuilder<User> {
        db.query(User.self)
    }
   
    func user(id: UUID) async throws -> User? {
        try await query().filter(\.$id == id).first()
    }
    
    func user(googleId: String) async throws -> User? {
        let user = try await query().filter(\.$googleId == googleId).first()
        return user
    }
    
    func user(hash: String) async throws -> User? {
        let user = try await query().filter(\.$token.$tokenHash == hash).first()
        return user
    }
    
    private func user(email: String) async throws -> User? {
        let user = try await query().filter(\.$email == email).first()
        return user
    }
    
    func createOrUpdate(_ userDTO: UserDTO) async throws -> User {
        if let user = try await user(googleId: userDTO.googleId) {
            return try await update(userDTO, with: user.id!)
        }
        else {
            return try await create(userDTO)
        }
    }
    
    private func create(_ userDTO: UserDTO) async throws -> User {
        let user = User(
            googleId: userDTO.googleId,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            email: userDTO.email,
            profilePicture: userDTO.profilePicture,
            token: Token(
                tokenHash: userDTO.tokenHash,
                expiresIn: userDTO.expiresIn
            ),
            settings: UserSettings(
                retentionRate: FSRSConfigs.defaultRetention
            )
        )
        try await user.create(on: db)
        return user
    }
    
    func update(_ userDTO: UserDTO, with id: UUID) async throws -> User {
        if let user = try await query().filter(\.$id == id).first() {
            user.firstName = userDTO.firstName
            user.lastName = userDTO.lastName
            user.profilePicture = userDTO.profilePicture
            user.email = userDTO.email
            user.token = Token(
                tokenHash: userDTO.tokenHash,
                expiresIn: userDTO.expiresIn
            )
            
            try await user.update(on: db)
            return user
        }
        else {
            throw FluentError.noResults
        }
    }
    
    func update(user: User) async throws {
        try await user.update(on: db)
    }
}
