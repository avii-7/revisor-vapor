//
//  UserMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥  on 23/08/25.
//

struct UserMapper {
    
    private init() { }
    
    static func mapToDTO(_ user: GoogleUser, token: GoogleTokenResponse) -> NewUserRequestDTO {
        NewUserRequestDTO(
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
}
