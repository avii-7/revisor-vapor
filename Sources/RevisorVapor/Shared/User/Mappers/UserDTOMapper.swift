//
//  UserDTOMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 23/08/25.
//

struct UserDTOMapper {
    
    private init() { }
    
    static func map(_ user: GoogleUser, token: GoogleTokenResponse) -> UserDTO {
        UserDTO(
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
