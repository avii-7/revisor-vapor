//
//  GoogleAuthController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 18/08/25.
//

import Vapor

struct GoogleAuthController: RouteCollection {
    
    let authState = UUID().uuidString
    
    // auth/google/callback
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(["auth", "google"])
        group.get(use: getGoogleAuthUrl)
    }
    
    private func getGoogleAuthUrl(_ req: Request) throws -> Response {
        var baseUrl = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        let redirectURI = Environment.get("GOOGLE_REDIRECT_URI")!
        let clientId = Environment.get("GOOGLE_CLIENT_ID")!
        
        let params = [
            "client_id": clientId,
            "redirect_uri": redirectURI,
            "response_type": "code",
            "scope": "email openid profile",
            "access_type": "offline",
            "state": authState
        ]
        
        baseUrl.append(queryItems: params.map({ URLQueryItem(name: $0.key, value: $0.value) }))
        
        let response = Response(status: .ok)
        try response.content.encode(baseUrl.absoluteString)
        return response
    }
}
