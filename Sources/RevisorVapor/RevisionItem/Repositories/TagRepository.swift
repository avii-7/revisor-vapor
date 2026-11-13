import Fluent
import Foundation

protocol TagRepository: Sendable {
    func tags(for userID: UUID) async throws -> [RevisionItemTag]
}

struct TagPostgresRepository: TagRepository {
    
    private let db: any Database
    
    init(db: any Database) {
        self.db = db
    }
    
    func tags(for userID: UUID) async throws -> [RevisionItemTag] {
        try await RevisionItemTag.query(on: db)
            .group(.or) { group in
                group.filter(\.$isPredefined == true)
                    .filter(\.$userId == userID)
            }
            .sort(\.$title, .ascending)
            .all()
    }
}
