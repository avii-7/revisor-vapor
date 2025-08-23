//
//  User.swift
//  RevisorVapor
//
//  Created by Avii 🔥  on 23/08/25.
//

import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "email")
    var email: String
    
    @OptionalField(key: "profile_picture")
    var profilePicture: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Group(key: "token")
    var token: GoogleToken
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }
    
    init(firstName: String, lastName: String, email: String, profilePicture: String? = nil, token: GoogleToken) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePicture = profilePicture
        self.token = token
    }
}
