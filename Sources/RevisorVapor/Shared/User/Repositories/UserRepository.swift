//
//  UserRepository.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//
import Foundation

protocol UserRespository: Sendable {
    
    func createUser(_ user: NewUserRequestDTO) async throws -> UserDTO
}
