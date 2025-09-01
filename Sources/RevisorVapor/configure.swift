import Vapor
import JWT
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                port: 5432,
                username: "avii",
                database: "revisor",
                tls: .disable
            )
        ),
        as: .psql
    )
    
    app.migrations.add(MigrationV1())

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://localhost:3000"),
        allowedMethods: [.GET, .POST, .PUT, .DELETE],
        allowedHeaders: [.authorization, .contentType, .accept, .origin, .accessControlAllowOrigin]
    )
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    let secretKey = Environment.get("SECRET_KEY")!
    await app.jwt.keys.add(hmac: .init(from: secretKey), digestAlgorithm: .sha256)

    // register routes
    try routes(app)
}
