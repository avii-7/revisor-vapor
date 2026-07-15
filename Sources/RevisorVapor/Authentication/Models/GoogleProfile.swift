//
//  GoogleProfile.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 21/08/25.
//

import Foundation

struct GoogleUser: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let picture: String?
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "given_name"
        case lastName = "family_name"
        case picture
        case email
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.picture = try container.decodeIfPresent(String.self, forKey: .picture)
        self.email = try container.decode(String.self, forKey: .email)
    }
}
