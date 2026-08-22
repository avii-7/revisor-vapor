//
//  RevisionStatDTO.swift
//  RevisorVapor
//
//  Created by Arun on 08/08/26.
//

import Vapor

struct RevisionStatDTO: Content {
    
    let id: String
    
    let title: String
    
    let value: String
}

extension RevisionStatDTO {

    init(type: RevisionStat, value: String) {
        self.id = type.id
        self.title = type.title
        self.value = value
    }
}

enum RevisionStat: Identifiable {
    case totalItems
    case totalRevisions
    case dueRevisionItems
    
    var id: String {
        switch self {
        case .totalItems: "total_items"
        case .totalRevisions: "total_revisions"
        case .dueRevisionItems: "due_revision_items"
        }
    }
    
    var title: String {
        switch self {
        case .totalItems: "Total items"
        case .totalRevisions: "Total revisions"
        case .dueRevisionItems: "Due Revision Items"
        }
    }
}
