//
//  UserDTO.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Foundation
import Vapor

struct UserDTO {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
    let token: GoogleTokenDTO
}

struct GoogleUserDTO {
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
    let token: GoogleTokenDTO
}

struct GoogleTokenDTO {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}
