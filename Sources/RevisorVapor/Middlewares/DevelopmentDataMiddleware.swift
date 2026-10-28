import Fluent
import Vapor

/// Seed before the first protected response, including for users with an existing session.
struct DevelopmentDataMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        if request.application.environment == .development {
            let user = try request.auth.require(UserAuthenticatable.self)
            try await DevelopmentRevisionSeed().prepare(for: user.userId, on: request.db)
        }

        return try await next.respond(to: request)
    }
}
