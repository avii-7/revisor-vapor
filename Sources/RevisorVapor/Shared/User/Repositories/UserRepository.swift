//
//  UserRepository.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Fluent

protocol UserRepository: Sendable {
    
    func get(by email: String) async throws -> UserDTO?
    
    func add(_ userDTO: GoogleUserDTO) async throws
    
    func create(_ userDTO: GoogleUserDTO) async throws
    
    func update(_ userDTO: GoogleUserDTO) async throws
}

final class UserPostgresRepository: UserRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query() -> QueryBuilder<User> {
        db.query(User.self)
    }
    
    func get(by email: String) async throws -> UserDTO? {
        let user = try await getUser(by: email)
        
        if let user {
            return UserMapper.map(user)
        }
        return nil
    }
    
    private func getUser(by email: String) async throws -> User? {
        let user = try await query().filter(\.$email == email).first()
        return user
    }
    
    func add(_ userDTO: GoogleUserDTO) async throws {
        if try await getUser(by: userDTO.email) != nil {
            try await update(userDTO)
        }
        else { // User doesn't exists
            try await create(userDTO)
        }
    }
    
    func create(_ userDTO: GoogleUserDTO) async throws {
        let user = UserMapper.map(userDTO)
        try await user.create(on: db)
    }
    
    func update(_ userDTO: GoogleUserDTO) async throws {
        if let user = try await query().filter(\.$email == userDTO.email).first() {
            user.firstName = userDTO.firstName
            user.lastName = userDTO.lastName
            user.profilePicture = userDTO.profilePicture
            user.email = userDTO.email
            
            user.token = .init(
                accessToken: userDTO.token.accessToken,
                refreshToken: userDTO.token.refreshToken,
                expiresIn: userDTO.token.expiresIn
            )
            
            try await user.update(on: db)
        }
    }
}
