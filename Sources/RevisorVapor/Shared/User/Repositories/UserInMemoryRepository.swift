//
//  UserInMemoryRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

final class UserInMemoryRepository: UserRepository, @unchecked Sendable {
    
    private var users: [NewUserRequestDTO]
    
    init(users: [NewUserRequestDTO] = []) {
        self.users = users
    }
    
    func createUser(_ userDTO: NewUserRequestDTO) async throws {
        users.append(userDTO)
    }
}
