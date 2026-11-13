//
//  TagsController.swift
//  RevisorVapor
//
//  Created by A7 - P on 13/11/26.
//

import Vapor

final class TagsController: RouteCollection, Sendable {

    private let repository: any TagRepository

    init(repository: any TagRepository) {
        self.repository = repository
    }

    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(["tags"])

        group.get(use: allTags)
    }

    private func allTags(req: Request) async throws -> Response {
        let user = try req.auth.require(UserAuthenticatable.self)
        let tags = try await repository.tags(for: user.userId)
        let dto = TagsDTO(tags: try tags.map { try TagMapper.map($0) })

        let response = Response(status: .ok)
        try response.content.encode(dto)
        return response
    }
}
