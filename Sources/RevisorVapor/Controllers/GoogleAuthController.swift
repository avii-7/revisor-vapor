//
//  GoogleAuthController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 18/08/25.
//

import Vapor

struct GoogleToken: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
    }
}

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
        
        baseUrl.append(queryItems: params.toQueryItems())
        
        let response = Response(status: .ok)
        try response.content.encode(baseUrl.absoluteString)
        return response
    }

    private func authCallback(_ req: Request) async throws -> Response {
        
        guard let query = req.url.query else {
            return Response(status: .badRequest)
        }
        
        let queryItems: [String: String] = query.split(separator: "&").reduce(into: [:]) { partialResult, item in
            let keyValuePair = item.split(separator: "=")
            guard keyValuePair.count >= 2 else { return }
            let key = String(keyValuePair[0])
            let value = String(keyValuePair[1])
            partialResult[key] = value
        }
        
        guard queryItems["state"] == authState else {
            return Response(status: .unauthorized)
        }
        
        guard let code = queryItems["code"] else {
            return Response(status: .badRequest, body: "Missing code")
        }
        
        let tokens = try await exchangeAuthorizationCodeForTokens(using: code, req.client)
        
        print(tokens)
        
        return Response(status: .ok)
    }
    
    private func exchangeAuthorizationCodeForTokens(using code: String, _ client: any Client) async throws -> GoogleToken {
        let url = "https://oauth2.googleapis.com/token"
        
        let clientId = Environment.get("GOOGLE_CLIENT_ID")!
        let clientSecret = Environment.get("GOOGLE_CLIENT_SECRET")!
        let redirectURI = Environment.get("GOOGLE_REDIRECT_URI")!
    
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI
        ]
        
        do {
            
            let response = try await client.post(URI(string: url)) { request in
                try request.content.encode(params, as: .urlEncodedForm)
            }
            
            print(response.content.contentType ?? "Unknown content type")
            
            let token = try response.content.decode(GoogleToken.self)
            
            return token
        }
        catch {
            print(error)
        }
        
        return .init(
            accessToken: .empty,
            refreshToken: .empty,
            expiresIn: .min,
            tokenType: .empty,
            scope: .empty
        )
    }
}
