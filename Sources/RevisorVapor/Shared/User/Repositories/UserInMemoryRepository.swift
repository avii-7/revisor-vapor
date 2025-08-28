//
//  UserInMemoryRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

final class UserInMemoryRepository: UserRepository, @unchecked Sendable {
    
    private var users: [GoogleUserDTO]
    
    init(users: [GoogleUserDTO] = []) {
        self.users = users
    }
    
    func get(by email: String) async throws -> UserDTO? {
//        if let user = users.first(where: { $0.email == email }) {
//            return UserMapper.map(user)
//        }
        return nil
    }
    
    func add(_ userDTO: GoogleUserDTO) async throws {
        
//        let existingUserDTO = try await get(by: userDTO.email)
//        
//        if let existingUserDTO {
//            try await update(existingUserDTO)
//        }
//        else {
//            try await create(userDTO)
//        }
    }
    
    func create(_ userDTO: GoogleUserDTO) async throws {
        users.append(userDTO)
    }
    
    func update(_ userDTO: GoogleUserDTO) async throws {
        let index = users.firstIndex { $0.email == userDTO.email }!
        users[index] = userDTO
    }
}
