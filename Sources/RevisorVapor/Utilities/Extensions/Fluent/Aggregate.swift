//
//  Aggregate.swift
//  RevisorVapor
//
//  Created by Arun on 08/08/26.
//

import Fluent
import Foundation

extension QueryBuilder {
    
    public func sum<Field>(_ key: KeyPath<Model, GroupPropertyPath<Model, Field>>) async throws -> Int?
    where Field: QueryableProperty, Field.Model == GroupPropertyPath<Model, Field>.Model, Field.Value == Int {

        if let result = try await self.aggregate(.sum, Model.path(for: key), as: Optional<Decimal>.self) {
            return NSDecimalNumber(decimal: result).intValue
        }
        else {
            return nil
        }
    }
}
