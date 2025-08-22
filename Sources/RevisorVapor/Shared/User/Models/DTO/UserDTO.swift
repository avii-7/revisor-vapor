//
//  UserDTO.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Foundation
import Vapor

struct NewUserRequestDTO: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
}

struct UserDTO: Content {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
}
