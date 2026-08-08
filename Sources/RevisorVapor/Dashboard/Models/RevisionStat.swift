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
    case totalProblems
    case totalRevisions
    
    var id: String {
        switch self {
        case .totalProblems: "total_problems"
        case .totalRevisions: "total_revisions"
        }
    }
    
    var title: String {
        switch self {
        case .totalProblems: "Total Problems"
        case .totalRevisions: "Total Revisions"
        }
    }
}
