//
//  UserMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

struct UserMapper {
    
    private init() { }
    
    static func map(_ user: GoogleUserDTO) -> User {
        User(
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.profilePicture,
            token: GoogleToken(
                accessToken: user.token.accessToken,
                refreshToken: user.token.refreshToken,
                expiresIn: user.token.expiresIn
            )
        )
    }
    
    static func map(_ user: GoogleUser, token: GoogleTokenResponse) -> GoogleUserDTO {
        GoogleUserDTO(
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.picture,
            token: .init(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                expiresIn: token.expiresIn
            )
        )
    }
    
    static func map(_ user: User) -> UserDTO {
        UserDTO(
            id: user.id!,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            profilePicture: user.profilePicture,
            token: .init(
                accessToken: user.token.accessToken,
                refreshToken: user.token.refreshToken,
                expiresIn: user.token.expiresIn
            )
        )
    }
}
