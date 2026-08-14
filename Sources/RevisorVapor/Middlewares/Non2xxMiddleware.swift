//
//  Non2xxMiddleware.swift
//  RevisorVapor
//
//  Created by Arun on 08/08/26.
//

import Vapor

struct Non2xxMiddleware: AsyncMiddleware {
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        
        if 200...299 ~= response.status.code {
            return response
        }
        
        request.logger.warning(
            "Non-2xx response",
            metadata: [
                "method": .string(request.method.rawValue),
                "path": .string(request.url.path),
                "status": .stringConvertible(response.status.code)
            ])
        
        return response
    }
}
