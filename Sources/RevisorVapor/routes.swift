import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    //auth/google/callback
    
    let group = app.grouped("api")
    try group.register(collection: GoogleAuthController())
}
