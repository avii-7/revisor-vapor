//
//  EnviornmentManager.swift
//  RevisorVapor
//
//  Created by Arun on 14/06/26.
//

import Vapor

enum EnvironmentKey {
    
    // Google
    case googleClientSecret
    case googleClientID
    case googleRedirectBackend   // Derived: BACKEND_URI + "/api/auth/google/callback"
    case googleRedirectFrontend  // Derived: FRONTEND_URI + "/auth/google/callback"
    
    // Redirection/base URIs
    case frontendURI
    case backendURI
    
    // JWT
    case jwtSecret
    
    // Database
    case dbHost
    case dbPort
    case dbName
    case dbUser
    case dbPassword
    
    // Raw key used for direct lookups when applicable
    var rawKey: String? {
        switch self {
        case .googleClientSecret: "GOOGLE_CLIENT_SECRET"
        case .googleClientID: "GOOGLE_CLIENT_ID"
        case .frontendURI: "FRONTEND_URI"
        case .backendURI: "BACKEND_URI"
        case .jwtSecret: "SECRET_KEY"
        case .dbHost: "DB_HOST"
        case .dbPort: "DB_PORT"
        case .dbName: "DB_NAME"
        case .dbUser: "DB_USER"
        case .dbPassword: "DB_PASSWORD"
        case .googleRedirectBackend, .googleRedirectFrontend: nil
        }
    }
    
    var value: String? {
        switch self {
        case .googleRedirectBackend:
            guard let base = EnvironmentKey.backendURI.value else { return nil }
            return base.appending("/api/auth/google/callback")
        case .googleRedirectFrontend:
            guard let base = EnvironmentKey.frontendURI.value else { return nil }
            return base.appending("/auth/google/callback")
        default:
            guard let key = rawKey else { return nil }
            return Environment.get(key)
        }
    }
}

extension Environment {
    
    static func get(_ key: EnvironmentKey) -> String? {
        key.value
    }
    
    static var getJWTSecretKey: String? {
        Environment.get(.jwtSecret)
    }
    
    static var dbConfig: DBConfig {
        let portString = Environment.get(.dbPort)!
        let port = Int(portString)!
        
        let host = Environment.get(.dbHost)!
        let name = Environment.get(.dbName)!
        let user = Environment.get(.dbUser)!
        let pass = Environment.get(.dbPassword)
        
        return DBConfig(
            hostName: host,
            port: port,
            user: user,
            password: pass,
            database: name
        )
    }
}

struct DBConfig {
    let hostName: String
    let port: Int
    let user: String
    let password: String?
    let database: String
}
