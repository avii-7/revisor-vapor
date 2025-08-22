//
//  UserController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 22/08/25.
//

import Vapor

struct UserController: RouteCollection, Sendable {
    
    private let repository: any UserRespository
    
    init(repository: any UserRespository) {
        self.repository = repository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("create", use: createUser)
    }
    
    private func createUser(req: Request) async throws -> Response {
        let decodedUser = try req.content.decode(NewUserRequestDTO.self)
        let user = try await repository.createUser(decodedUser)
        let response = Response(status: .created)
        try response.content.encode(user)
        return response
    }
}
