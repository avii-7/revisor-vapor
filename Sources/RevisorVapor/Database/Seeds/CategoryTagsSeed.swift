//
//  CategoryTagsSeed.swift
//  RevisorVapor
//
//  Created by Avii 🔥  on 12/09/25.
//

import Fluent

struct CategoryTagsSeed: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        let categories = ["Array", "Strings", "Tree", "Graph", "Dynamic Programming", "Sorting", "Sliding Window"]
        
        let categoryModels = categories.map { RevisionItemCategory(title: $0) }
        try await categoryModels.create(on: database)
        
        let tags = ["Amazon", "Facebook", "Adobe", "Google", "Microsoft", "Apple", "Oracle", "Meta", "Zomato", "Netflix", "Uber", "Snapchat", "KukuFM"]
        let tagModels = tags.map { RevisionItemTag(title: $0) }
        try await tagModels.create(on: database)
    }
    
    func revert(on database: any Database) async throws { }
}
