//
//  GoogleAuthController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 18/08/25.
//

import Vapor

struct GoogleAuthController: RouteCollection {
    
    let authState = UUID().uuidString
    
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(["auth", "google"])
        group.get(use: getGoogleAuthUrl)
        group.get("callback", use: authCallback)
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
    
    private func authCallback(_ req: Request) throws -> Response {
        
        guard let query = req.url.query else {
            return Response(status: .badRequest)
        }
        
        guard let queryItems = URLComponents(string: query)?.queryItems, queryItems.isEmpty == false else {
            return Response(status: .badRequest)
        }
        
        let dict = queryItems.reduce(into: [:]) { partialResult, item in
            partialResult[item.name] = item.value
        }
        
        guard dict["state"] == authState else {
            return Response(status: .unauthorized)
        }
        
        guard let code = dict["code"], code.isEmpty == false else {
            return Response(status: .unauthorized)
        }
        
        // Todo: Get userInfo

        return Response(status: .ok)
    }
}
