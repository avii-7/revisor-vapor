import Vapor

func routes(_ app: Application) throws {
    
    app.get { req async in
        "It works!"
    }
    
    let group = app.grouped("api")
    
    let userRepsitory =  UserPostgresRepository(db: app.db)
    let repository = RevisionPostgresRepository(db: app.db)
    let service = RevisionService(repository: repository, userRepository: userRepsitory)
    
    try group.register(collection: GoogleAuthController(userRepository: userRepsitory))
    
    let protectedGroup = group.grouped(UserAuthenticator())
        .grouped(UserAuthenticatable.guardMiddleware())
    
    try protectedGroup.register(collection: ProfileController(userRepository: userRepsitory))

    try protectedGroup.register(collection: RevisionController(service: service))
    
    try protectedGroup.register(
        collection: DashboardController(
            revisionService: service,
            userRepository: userRepsitory
        )
    )
}
