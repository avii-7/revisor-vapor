//
//  UserRepository.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Fluent

protocol UserRepository: Sendable {
    
    @discardableResult
    func add(_ userDTO: GoogleUserDTO) async throws -> UserDTO
    
    func get(by id: UUID) async throws -> UserDTO?
    
    func create(_ userDTO: GoogleUserDTO) async throws -> UserDTO
    
    func  update(_ userDTO: GoogleUserDTO, with id: UUID) async throws -> UserDTO
}

final class UserPostgresRepository: UserRepository {
    
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
    
    func get(by id: UUID) async throws -> UserDTO? {
        if let user = try await query().filter(\.$id == id).first() {
            return UserMapper.map(user)
        }
        return nil
    }
    
    func add(_ userDTO: GoogleUserDTO) async throws -> UserDTO {
        if let user = try await getUser(by: userDTO.email) {
            try await update(userDTO, with: user.id!)
        }
        else {
            try await create(userDTO)
        }
    }
    
    func create(_ userDTO: GoogleUserDTO) async throws -> UserDTO {
        
        let user = User(
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            email: userDTO.email,
            profilePicture: userDTO.profilePicture,
            token: GoogleToken(
                accessToken: userDTO.token.accessToken,
                refreshToken: userDTO.token.refreshToken,
                expiresIn: userDTO.token.expiresIn
            )
        )
        
        try await user.create(on: db)
        
        return UserMapper.map(user)
    }
    
    func update(_ userDTO: GoogleUserDTO, with id: UUID) async throws -> UserDTO {
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
            
            return UserMapper.map(user)
        }
        else {
            throw FluentError.noResults
        }
    }
}
