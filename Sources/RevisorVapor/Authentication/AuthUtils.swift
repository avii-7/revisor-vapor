//
//  AuthUtils.swift
//  RevisorVapor
//
//  Created by Arun on 15/07/26.
//

import Foundation
import CryptoKit
import Vapor

enum AuthUtils {
    
    static func makeHash(token: String) -> String {
        let digest = SHA256.hash(data: Data(token.utf8))
        let hash = digest.map { String(format: "%02x", $0)}.joined()
        return hash
    }
    
    static func compare(hash: String, token: String) -> Bool {
        let tokenHash = makeHash(token: token)
        return hash == tokenHash
    }
    
    static func jwtTokenCookie(token: String, expire: Date, maxAge: Int = Int(TimeConstants.oneHour), isSecure: Bool) -> HTTPCookies.Value {
        HTTPCookies.Value(
            string: token,
            expires: expire,
            maxAge: maxAge,
            // Only send this cookie over HTTPS. Keep it `false` for local deployments because it use `http` instead of `https`
            isSecure: isSecure,
            // JavaScript cannot read this cookie.
            isHTTPOnly: true,
            // Control when the browser sends the cookie across sites.
            // .lax for same-site apps, .none for frontend/backend on different sites
            sameSite: HTTPCookies.SameSitePolicy.none
        )
    }
    
    static func refreshTokenCookie(token: String, expire: Date, maxAge: Int = Int(TimeConstants.ninetyDays), isSecure: Bool) -> HTTPCookies.Value {
        HTTPCookies.Value(
            string: token,
            expires: expire,
            maxAge: maxAge,
            isSecure: isSecure,
            isHTTPOnly: true,
            sameSite: HTTPCookies.SameSitePolicy.none
        )
    }
    
    
    static func expiredCookie(isSecure: Bool) -> HTTPCookies.Value {
        HTTPCookies.Value(
            string: String.empty,
            expires: .now,
            maxAge: .zero,
            // Only send this cookie over HTTPS. Keep it `false` for local deployments because it use `http` instead of `https`
            isSecure: isSecure,
            // JavaScript cannot read this cookie.
            isHTTPOnly: true,
            // Control when the browser sends the cookie across sites.
            // .lax for same-site apps, .none for frontend/backend on different sites
            sameSite: HTTPCookies.SameSitePolicy.none
        )
    }
}
