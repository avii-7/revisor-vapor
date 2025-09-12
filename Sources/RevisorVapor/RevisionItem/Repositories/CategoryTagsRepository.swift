//
//  CategoryTagsRepository.swift
//  RevisorVapor
//
//  Created by Avii 🔥 on 12/09/25.
//

import Fluent

protocol RevisionItemCategoryTagsRepository {
    
}

struct RevisionItemCategoryTagsPostgresRepository: RevisionItemCategoryTagsRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
}
