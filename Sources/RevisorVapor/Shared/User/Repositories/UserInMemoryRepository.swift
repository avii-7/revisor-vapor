//
//  UserInMemoryRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

import Foundation

final class UserInMemoryRepository: UserRepository, @unchecked Sendable {
    
    private var users: [UserDTO]
    
    init(users: [UserDTO] = []) {
        self.users = users
    }
    
    func add(_ userDTO: GoogleUserDTO) async throws -> UserDTO {
        fatalError("method is not implemented")
    }
    
    func get(by id: UUID) async throws -> UserDTO? {
        users.first(where: { $0.id == id })
    }
    
    func create(_ userDTO: GoogleUserDTO) async throws -> UserDTO {
        fatalError("method is not implemented")
    }
    
    func update(_ userDTO: GoogleUserDTO, with id: UUID) async throws -> UserDTO {
        fatalError("method is not implemented")
    }
}
