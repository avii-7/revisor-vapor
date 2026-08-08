//
//  Aggregate.swift
//  RevisorVapor
//
//  Created by Arun on 08/08/26.
//

import Fluent

extension QueryBuilder {
    
    public func sum<Field>(_ key: KeyPath<Model, GroupPropertyPath<Model, Field>>) async throws -> Field.Value?
    where Field: QueryableProperty, Field.Model == GroupPropertyPath<Model, Field>.Model, Field.Value: Sendable {
        try await self.aggregate(.sum, key)
    }

    public func aggregate<Field, Result>(
        _ method: DatabaseQuery.Aggregate.Method,
        _ field: KeyPath<Model, GroupPropertyPath<Model, Field>>,
        as: Result.Type = Result.self
    ) async throws -> Result
        where Field: QueryableProperty, Field.Model == GroupPropertyPath<Model, Field>.Model, Result: Codable & Sendable
    {
        try await self.aggregate(method, Model.path(for: field), as: Result.self)
    }
}
