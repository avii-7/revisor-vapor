//
//  RevisionItemCategory.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 12/09/25.
//

import Foundation
import Fluent

final class RevisionItemCategory: Model, @unchecked Sendable {
    
    static let schema: String = "revision_item_categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "isPredefined")
    var isPredefined: Bool
    
    init() { }
    
    init(userId: UUID, title: String) {
        self.userId = userId
        self.title = title
        self.isPredefined = false
    }
    
    /// For predefined categories.
    init(title: String) {
        self.title = title
        self.isPredefined = true
    }
}

