import Vapor

func routes(_ app: Application) throws {
    
    app.get { req async in
        "It works!"
    }
    
    let group = app.grouped("api")
    
    let userRepsitory: any UserRepository
    
    if app.environment == .testing {
        userRepsitory = UserInMemoryRepository()
    }
    else {
        userRepsitory = UserPostgresRepository(db: app.db)
    }
    
    try group.register(collection: GoogleAuthController(userRepository: userRepsitory))
    
    let protectedGroup = group.grouped(UserAuthenticator())
    
    try protectedGroup.register(collection: ProfileController(userRepository: userRepsitory))
}

final class UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(as: UserPayload.self)
        let email = payload.subject.value
        try request.content.encode(email)
    }
}
