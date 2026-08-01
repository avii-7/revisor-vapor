//
//  AuthController.swift
//  RevisorVapor
//
//  Created by Arun's Macbook on 18/08/25.
//

import Vapor
import JWTKit

extension AuthController {
    
    enum Endpoint: String {
        case authUrl = "https://accounts.google.com/o/oauth2/v2/auth"
        case token = "https://oauth2.googleapis.com/token"
        case profile = "https://openidconnect.googleapis.com/v1/userinfo"
    }
}

struct AuthController: RouteCollection, Sendable {
    
    let authState = UUID().uuidString
    
    private let userRepository: any UserRepository
    
    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let authGroup = routes.grouped(["auth"])
        
        let googleGroup = authGroup.grouped(["google"])
        googleGroup.get(use: getGoogleAuthUrl)
        googleGroup.get("callback", use: authCallback)

        authGroup.post("refresh-token", use: refreshToken)
        authGroup.get("session", use: authSessionStatus)
        authGroup.get("logout", use: logout)
    }
    
    private func getGoogleAuthUrl(_ req: Request) throws -> Response {
        var baseUrl = URL(string: Endpoint.authUrl.rawValue)!

        let redirectURI = Environment.get(.googleRedirectBackend)!

        let clientId = Environment.get(.googleClientID)!
        
        let params = [
            "client_id": clientId,
            "redirect_uri": redirectURI,
            "response_type": "code",
            "scope": "openid profile email",
            "access_type": "offline",
            "state": authState,
            "prompt": "consent select_account"
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
        
        // TODO: USE query decoder
        // req.query.decode(Model.self)
        
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
        
        // Refresh Token
        let refreshToken = Data([UInt8].random(count: 32)).base64EncodedString()
        let refreshTokenHash = AuthUtils.makeHash(token: refreshToken)
        let refreshTokenExpiresIn = TimeConstants.ninetyDaysFromNow
        
        let newUserRequestDTO = UserMapper.map(googleUser, tokenHash: refreshTokenHash, expiresIn: refreshTokenExpiresIn)
        let user = try await userRepository.createOrUpdate(newUserRequestDTO)
        
        guard let userID = user.id else {
            return Response(status: .internalServerError)
        }

        let payload = UserJWTPayload(
            issuer: .revisor,
            subject: SubjectClaim(value: userID.uuidString),
            expiration: .oneHour
        )
        
        let jwtToken = try await req.jwt.sign(payload)
        
        let clientRedirectURI = Environment.get(.googleRedirectFrontend)!
        
        let response = req.redirect(to: clientRedirectURI)
        
        response.cookies[CookiesConstant.jwtToken] = AuthUtils.jwtTokenCookie(
            token: jwtToken,
            expire: payload.expiration.value,
            isSecure: req.application.environment == .production
        )
        
        response.cookies[CookiesConstant.refreshToken] = AuthUtils.refreshTokenCookie(
            token: refreshToken,
            expire: refreshTokenExpiresIn,
            isSecure: req.application.environment == .production
        )

        return response
    }
    
    private func exchangeAuthorizationCodeForToken(using code: String, _ client: any Client) async throws -> GoogleTokenResponse  {
        
        let percentDecoded = code.removingPercentEncoding ?? code

        let url = Endpoint.token.rawValue
        
        let clientId = Environment.get(.googleClientID)!
        
        let clientSecret = Environment.get(.googleClientSecret)!
        
        let redirectURI = Environment.get(.googleRedirectBackend)!
    
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
    
    private func refreshToken(_ req: Request) async throws -> Response {
        
        let refreshTokenCookie = req.cookies[CookiesConstant.refreshToken]
        
        guard let refreshTokenCookie else { throw Abort(.unauthorized) }
        
        let refreshToken = refreshTokenCookie.string
        
        if refreshToken.isEmpty {
            throw Abort(.unauthorized)
        }
        
        let hash = AuthUtils.makeHash(token: refreshToken)
        let user = try await userRepository.user(hash: hash)
        
        guard let user else { throw Abort(.unauthorized) }
        
        guard user.token.expiresIn > Date.now else { throw Abort(.unauthorized) }
        
        let payload = UserJWTPayload(
            issuer: .revisor,
            subject: SubjectClaim(value: user.id!.uuidString),
            expiration: .oneHour
        )
        
        let jwtToken = try await req.jwt.sign(payload)
        
        let jwtTokenCookie = AuthUtils.jwtTokenCookie(
            token: jwtToken,
            expire: payload.expiration.value,
            isSecure: req.application.environment == .production
        )
        
        // Refresh Token
        let newRefreshToken = Data([UInt8].random(count: 32)).base64EncodedString()
        let newRefreshTokenHash = AuthUtils.makeHash(token: newRefreshToken)
        let newRefreshTokenExpiresIn = TimeConstants.ninetyDaysFromNow
        
        let newRefreshTokenCookie = AuthUtils.refreshTokenCookie(
            token: newRefreshToken,
            expire: newRefreshTokenExpiresIn,
            isSecure: req.application.environment == .production
        )
        
        user.token.tokenHash = newRefreshTokenHash
        user.token.expiresIn = newRefreshTokenExpiresIn
        try await userRepository.update(user: user)
        
        let response = Response()
        response.cookies[CookiesConstant.jwtToken] = jwtTokenCookie
        response.cookies[CookiesConstant.refreshToken] = newRefreshTokenCookie
        
        return response
    }
    
    private func authSessionStatus(_ req: Request) async throws -> Response {
        let jwtTokenCookie = req.cookies[CookiesConstant.jwtToken]
        
        guard let jwtToken = jwtTokenCookie?.string else { throw Abort(.unauthorized) }
        
        _ = try await req.jwt.verify(jwtToken, as: UserJWTPayload.self)
        
        return Response(status: .ok)
    }
    
    private func logout(_ req: Request) async throws -> Response {
        let jwtTokenCookie = req.cookies[CookiesConstant.jwtToken]
        
        guard let jwtToken = jwtTokenCookie?.string else { throw Abort(.unauthorized) }
        
        _ = try await req.jwt.verify(jwtToken, as: UserJWTPayload.self)
        
        return Response(status: .ok)
    }
}
