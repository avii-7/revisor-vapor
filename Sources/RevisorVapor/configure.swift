import Vapor
import JWT
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let config = getDBConfigs(using: app.environment)
    
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: config.hostName,
                port: config.port,
                username: config.user,
                password: config.password,
                database: config.database,
                tls: .disable
            )
        ),
        as: .psql
    )
    
    app.migrations.add(MigrationV1())
    app.migrations.add(CategoryTagsSeed())

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://localhost:3000"),
        allowedMethods: [.GET, .POST, .PUT, .PATCH, .DELETE],
        allowedHeaders: [.authorization, .contentType, .accept, .origin, .accessControlAllowOrigin]
    )
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    let secretKey = Environment.get("SECRET_KEY")!
    await app.jwt.keys.add(hmac: .init(from: secretKey), digestAlgorithm: .sha256)

    // register routes
    try routes(app)
}


private func getDBConfigs(using environment: Environment) -> DBConfig {
    
    let dbPortString = Environment.get("DB_PORT")!
    let dbPort = Int(dbPortString)!
    
    let dbConfig = DBConfig(
        hostName: Environment.get("DB_HOST")!,
        port: dbPort,
        user: Environment.get("DB_USER")!,
        password: Environment.get("DB_PASSWORD"),
        database: Environment.get("DB_NAME")!
    )
    
    return dbConfig
}

private struct DBConfig {
    let hostName: String
    let port: Int
    let user: String
    let password: String?
    let database: String
}
