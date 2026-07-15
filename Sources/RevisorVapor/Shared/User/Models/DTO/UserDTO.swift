//
//  UserDTO.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Foundation
import Vapor

struct UserDTO {
    let googleId: String
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String?
    let tokenHash: String
    let expiresIn: Date
}
