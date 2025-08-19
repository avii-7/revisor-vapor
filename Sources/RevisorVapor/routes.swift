import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    let group = app.grouped("api")
    try group.register(collection: GoogleAuthController())
}
