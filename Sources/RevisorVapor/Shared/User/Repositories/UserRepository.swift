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
    func add(_ userDTO: GoogleUserDTO) async throws -> User
    
    func get(by id: UUID) async throws -> User?
    
    func update(_ userDTO: GoogleUserDTO, with id: UUID) async throws -> User
}

struct UserPostgresRepository: UserRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query() -> QueryBuilder<User> {
        db.query(User.self)
    }
    
    private func getUser(by email: String) async throws -> User? {
        let user = try await query().filter(\.$email == email).first()
        return user
    }
    
    func get(by id: UUID) async throws -> User? {
        try await query().filter(\.$id == id).first()
    }
    
    func add(_ userDTO: GoogleUserDTO) async throws -> User {
        if let user = try await getUser(by: userDTO.email) {
            return try await update(userDTO, with: user.id!)
        } else {
            return try await create(userDTO)
        }
    }
    
    private func create(_ userDTO: GoogleUserDTO) async throws -> User {
        let user = User(
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            email: userDTO.email,
            profilePicture: userDTO.profilePicture,
            token: GoogleToken(
                accessToken: userDTO.token.accessToken,
                refreshToken: userDTO.token.refreshToken,
                expiresIn: userDTO.token.expiresIn
            ),
            settings: UserSettings(
                retentionRate: 0.9
            )
        )
        try await user.create(on: db)
        return user
    }
    
    func update(_ userDTO: GoogleUserDTO, with id: UUID) async throws -> User {
        if let user = try await query().filter(\.$id == id).first() {
            user.firstName = userDTO.firstName
            user.lastName = userDTO.lastName
            user.profilePicture = userDTO.profilePicture
            user.email = userDTO.email

            user.token = GoogleToken(
                accessToken: userDTO.token.accessToken,
                refreshToken: userDTO.token.refreshToken,
                expiresIn: userDTO.token.expiresIn
            )

            try await user.update(on: db)
            return user
        } else {
            throw FluentError.noResults
        }
    }
}
