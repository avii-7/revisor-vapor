//
//  UserInMemoryRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

final class UserInMemoryRepository: UserRepository, @unchecked Sendable {
    
    private var users: [UserDTO]
    
    init(users: [UserDTO] = []) {
        self.users = users
    }
    
    func get(by email: String) async throws -> UserDTO? {
        users.first { $0.email == email }
    }
    
    func add(_ userDTO: UserDTO) async throws {
        
        let existingUserDTO = try await get(by: userDTO.email)
        
        if let existingUserDTO {
            try await update(existingUserDTO)
        }
        else {
            try await create(userDTO)
        }
    }
    
    func create(_ userDTO: UserDTO) async throws {
        users.append(userDTO)
    }
    
    func update(_ userDTO: UserDTO) async throws {
        let index = users.firstIndex { $0.email == userDTO.email }!
        users[index] = userDTO
    }
}
