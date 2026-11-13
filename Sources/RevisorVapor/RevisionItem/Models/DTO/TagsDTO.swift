//
//  TagsDTO.swift
//  RevisorVapor
//
//  Created by A7 - P on 13/11/26.
//

import Vapor

struct TagsDTO: Content {
    
    let tags: [TagDTO]
}

struct TagDTO: Content {
    
    let id: UUID
    
    let name: String
}
