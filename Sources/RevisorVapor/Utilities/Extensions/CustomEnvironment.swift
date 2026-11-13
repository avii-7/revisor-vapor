//
//  CustomEnvironment.swift
//  RevisorVapor
//
//  Created by Arun on 22/08/26.
//

import Vapor

extension Environment {
    
    static var staging: Environment {
        .custom(name: "staging")
    }
}
