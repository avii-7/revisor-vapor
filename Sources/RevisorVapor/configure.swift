import Vapor
import JWT
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let config = Environment.dbConfig
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
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

    let feURI = Environment.get(.frontendURI)!
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom(feURI),
        allowedMethods: [.GET, .POST, .PUT, .PATCH, .DELETE],
        allowedHeaders: [.authorization, .contentType, .accept, .origin],
        allowCredentials: true
    )
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    
    let secretKey = Environment.getJWTSecretKey!
    await app.jwt.keys.add(hmac: .init(from: secretKey), digestAlgorithm: .sha256)

    // register routes
    try routes(app)
}
