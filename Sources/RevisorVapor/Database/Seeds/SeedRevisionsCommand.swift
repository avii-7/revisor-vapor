import Fluent
import Vapor

struct SeedRevisionsCommand: AsyncCommand {
    
    struct Signature: CommandSignature {
        @Argument(name: "user-id", help: "UUID of the user to seed revision items for")
        var userID: String
    }

    let help = "Create sample revision items with predefined tags for a development user."

    func run(using context: CommandContext, signature: Signature) async throws {
        guard context.application.environment == .development else {
            throw Abort(.forbidden, reason: "Sample seeding is only available in development.")
        }
        guard let userID = UUID(uuidString: signature.userID) else {
            throw Abort(.badRequest, reason: "user-id must be a valid UUID.")
        }

        let count = try await DevelopmentRevisionSeed().prepare(for: userID, on: context.application.db)
        if count == 0 {
            context.console.print("Skipped: this user already has revision items.")
        } else {
            context.console.print("Created \(count) sample revision items with predefined tags.")
        }
    }
}
