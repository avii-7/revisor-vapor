//
//  Dictionary+Extensions.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 21/08/25.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    func toQueryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
