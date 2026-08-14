//
//  PageRequestDTO.swift
//  RevisorVapor
//
//  Created by Arun on 08/07/26.
//

import FluentKit
import Vapor

struct PageRequestDTO: Decodable {
    
    let page: Int
    
    let size: Int
}

struct PageMetadataDTO: Content {
    
    let page: Int

    let per: Int

    /// Total number of items available.
    let total: Int
    
    /// Computed total number of pages with `1` being the minimum.
    let pageCount: Int
}

struct PaginatedDTO<T: Content>: Content {
    
    let items: [T]
    
    let metadata: PageMetadataDTO
}


enum PaginationMapper {
    
    static func map<X, Y>(_ model: Page<X>, transform: (X) -> Y ) -> PaginatedDTO<Y> {
                
        let dbMetaData = model.metadata
        
        let metaData = PageMetadataDTO(
            page: dbMetaData.page,
            per: dbMetaData.per,
            total: dbMetaData.total,
            pageCount: dbMetaData.pageCount
        )
        
        let items = model.items.map(transform)
        
        return PaginatedDTO(items: items, metadata: metaData)
    }
}
