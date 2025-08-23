//
//  GoogleAuthController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 18/08/25.
//

import Vapor

extension GoogleAuthController {
    
    enum Endpoint: String {
        case authUrl = "https://accounts.google.com/o/oauth2/v2/auth"
        case token = "https://oauth2.googleapis.com/token"
        case profile = "https://openidconnect.googleapis.com/v1/userinfo"
    }
}

struct GoogleAuthController: RouteCollection, Sendable {
    
    let authState = UUID().uuidString
    
    private let userRepository: any UserRepository
    
    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(["auth", "google"])
        group.get(use: getGoogleAuthUrl)
        group.get("callback", use: authCallback)
    }
    
    private func getGoogleAuthUrl(_ req: Request) throws -> Response {
        var baseUrl = URL(string: Endpoint.authUrl.rawValue)!
        let redirectURI = Environment.get("GOOGLE_REDIRECT_URI")!
        let clientId = Environment.get("GOOGLE_CLIENT_ID")!
        
        let params = [
            "client_id": clientId,
            "redirect_uri": redirectURI,
            "response_type": "code",
            "scope": "openid profile email",
            "access_type": "offline",
            "state": authState,
            "prompt": "consent"
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
        
        let token = try await exchangeAuthorizationCodeForToken(using: code, req.client)
        let googleUser = try await fetchUserInfo(using: token, req.client)
        
        let newUserRequestDTO = UserMapper.mapToDTO(googleUser, token: token)
        try await userRepository.createUser(newUserRequestDTO)
        
        let payload = UserPayload(subject: .init(value: googleUser.email))
        let jwtToken = try await req.jwt.sign(payload)
        
        let responseBody = AuthenticationResponse(success: true, token: jwtToken)
        
        let clientRedirectURI = Environment.get("CLIENT_REDIRECT_URL")!
        
        let response = req.redirect(to: clientRedirectURI)
        try response.content.encode(responseBody)
        return response
    }
    
    private func exchangeAuthorizationCodeForToken(using code: String, _ client: any Client) async throws -> GoogleTokenResponse  {
        
        let percentDecoded = code.removingPercentEncoding ?? code

        let url = Endpoint.token.rawValue
        
        let clientId = Environment.get("GOOGLE_CLIENT_ID")!
        let clientSecret = Environment.get("GOOGLE_CLIENT_SECRET")!
        let redirectURI = Environment.get("GOOGLE_REDIRECT_URI")!
    
        let params = [
            "code": percentDecoded,
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"
        ]
        
        let response = try await client.post(URI(string: url)) { request in
            try request.content.encode(params, as: .urlEncodedForm)
        }
        
        let token = try response.content.decode(GoogleTokenResponse.self)
        
        return token
    }
    
    private func fetchUserInfo(using token: GoogleTokenResponse, _ client: any Client) async throws -> GoogleUser {
        let url = Endpoint.profile.rawValue
        let header = ("Authorization", "Bearer \(token.accessToken)")
        let response = try await client.get(URI(string: url), headers: .init([header]))
        let user = try response.content.decode(GoogleUser.self)
        return user
    }
}
