//
//  UserRepository.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//
import Vapor
import Fluent

protocol UserRepository: Sendable {
    
    func createUser(_ userDTO: NewUserRequestDTO) async throws
}

final class UserPostgresRepository: UserRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    private func query() -> QueryBuilder<User> {
        db.query(User.self)
    }
    
    func createUser(_ userDTO: NewUserRequestDTO) async throws {
        
        let tokenDTO = userDTO.token
        
        let token = GoogleToken(
            accessToken: tokenDTO.accessToken,
            refreshToken: tokenDTO.refreshToken,
            expiresIn: tokenDTO.expiresIn,
        )
        
        let user = User(
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            email: userDTO.email,
            profilePicture: userDTO.profilePicture, token: token
        )
        
        do {
            
            try await user.create(on: db)
            
        }
        catch {
            print(error)
        }
    }
    
//    func createUser(_ user: NewUserRequest) async throws -> UserResponse {
//        let user = User(
//            displayName: user.name,
//            authProvider: "test",
//            authProviderId: "test"
//        )
//        try await user.create(on: db)
//        return UserMapper.map(from: user)
//    }
//    
//    func getUsers() async throws -> [UserResponse] {
//        try await query().all().map { UserMapper.map(from: $0) }
//    }
//    
//    func getUser(id: UUID) async throws -> UserResponse? {
//        try await query()
//            .filter(\.$id == id)
//            .first()
//            .map { UserMapper.map(from: $0) }
//    }
//    
//    func deleteUser(by id: UUID) async throws {
//        try await query()
//            .filter(\.$id == id)
//            .delete()
//    }
}
