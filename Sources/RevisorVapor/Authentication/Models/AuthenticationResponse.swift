//
//  AuthenticationResponse.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Vapor

struct AuthenticationResponse: Content {
    let success: Bool
    let token: String
}
