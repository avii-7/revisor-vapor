import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://localhost:3000"),
        allowedMethods: [.GET, .POST, .PUT, .DELETE],
        allowedHeaders: []
    )
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    let secretKey = Environment.get("SECRET_KEY")!
    await app.jwt.keys.add(hmac: .init(from: secretKey), digestAlgorithm: .sha256)

    // register routes
    try routes(app)
}
