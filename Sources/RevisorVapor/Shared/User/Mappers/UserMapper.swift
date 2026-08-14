//
//  UserMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

import Foundation

enum UserMapper {

    static func map(_ user: GoogleUser, tokenHash: String, expiresIn: Date) -> UserDTO {
        UserDTO(
            googleId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.picture,
            tokenHash: tokenHash,
            expiresIn: expiresIn
        )
    }
    
//    static func map(_ user: User) -> UserDTO {
//        UserDTO(
//            id: user.id!,
//            firstName: user.firstName,
//            lastName: user.lastName,
//            email: user.email,
//            profilePicture: user.profilePicture,
//            token: .init(
//                accessToken: user.token.accessToken,
//                refreshToken: user.token.refreshToken,
//                expiresIn: user.token.expiresIn
//            )
//        )
//    }
}
