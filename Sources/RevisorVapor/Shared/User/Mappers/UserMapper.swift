//
//  UserMapper.swift
//  RevisorVapor
//
//  Created by Avii 🔥  on 23/08/25.
//

struct UserMapper {
    
    private init() { }
    
    static func map(_ user: UserDTO) -> User {
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
}
