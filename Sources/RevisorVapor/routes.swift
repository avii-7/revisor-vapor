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
