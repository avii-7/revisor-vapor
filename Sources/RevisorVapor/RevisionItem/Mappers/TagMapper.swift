import Fluent

enum TagMapper {
    
    static func map(_ tag: RevisionItemTag) throws -> TagDTO {
        TagDTO(id: try tag.requireID(), name: tag.title)
    }
}
