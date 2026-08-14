//
//  RevisionItemService.swift
//  RevisorVapor
//
//  Created by Arun on 26/06/26.
//

import Foundation
import FSRS
import FluentKit

enum RevisionServiceError: LocalizedError {
    case itemNotFound(_ id: UUID, _ userID: UUID)
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound(let id, let userID): " \(id) Item not found for the userID - \(userID)"
        }
    }
}

private extension MemoryState.CardState {
    
    var fsrsValue: Int {
        switch self {
        case .new: CardState.new.rawValue
        case .learning: CardState.learning.rawValue
        case .review: CardState.review.rawValue
        case .relearning: CardState.relearning.rawValue
        }
    }
}

private extension InputRating {
    
    var fsrsValue: Int {
        switch self {
        case .again: Rating.again.rawValue
        case .hard: Rating.hard.rawValue
        case .good: Rating.good.rawValue
        case .easy: Rating.easy.rawValue
        }
    }
}

final class RevisionService: Sendable {
    
    private let repository: any RevisionRepository
    
    private let userRepository: any UserRepository
    
    init(repository: any RevisionRepository, userRepository: any UserRepository) {
        self.repository = repository
        self.userRepository = userRepository
    }
    
    func revisionInfo(for userID: UUID) async throws -> RevisionInfo? {
        
        let hasRevisionItems = try await repository.hasRevisionItems(for: userID)
        
        guard hasRevisionItems else { return nil }
        
        if let dbItem = try await repository.firstDueRevisionItem(for: userID) {
            
            let preview = RevisionItemPreview(
                id: dbItem.id!,
                title: dbItem.title
            )

            let dueItemsCount = try await repository.dueRevisionItemCount(for: userID)
            
            return RevisionInfo(
                state: .ready,
                nextRevisionAt: nil,
                nextItem: preview,
                dueItemCount: dueItemsCount
            )
        }
        else if let nextRevisionItem = try await repository.nextRevisionItem(for: userID) {
            
            return RevisionInfo(
                state: .completed,
                nextRevisionAt: nextRevisionItem.memoryState.due,
                nextItem: nil,
                dueItemCount: .zero
            )
        }
        
        return nil
    }
    
    func revisionStats(for userID: UUID) async throws -> [RevisionStatDTO] {
        
        let revisionItemsCount = try await repository.revisionItemsCount(for: userID)
        
        var stats = [RevisionStatDTO]()
        
        if let revisionItemsCount {
            stats.append(RevisionStatDTO(type: .totalRevisions, value: String(revisionItemsCount)))
        }
        
        stats.append(RevisionStatDTO(type: .totalProblems, value: String(100)))

        return stats
    }
    
    func dueRevisionItems(for userId: UUID) async throws -> [RevisionItemResponseDTO] {
        do {
            let dbItems = try await repository.dueRevisionItems(for: userId)
            
            var items: [RevisionItemResponseDTO] = []
            
            let retention = try await getRetentionRate(using: userId)
            
            let scheduler = MemoryScheduler(retention: retention)
            
            for dbItem in dbItems {
                let nextRevision = try scheduler.nextRevision(of: dbItem.memoryState)
                let item = RevisionMapper.map(dbItem, nextRevision: nextRevision)
                items.append(item)
            }
            
            return items
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func previewRevisionItems(for userId: UUID) async throws -> [PreviewRevisionItemResponseDTO] {
        do {
            let dbItems = try await repository.previewRevisionItems(for: userId)
            return dbItems.map { RevisionMapper.map($0) }
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func revisionItems(for userId: UUID, paginationRequest: PageRequestDTO) async throws -> PaginatedDTO<PreviewRevisionItemResponseDTO> {
        do {
            let request = PageRequest(page: paginationRequest.page, per: paginationRequest.size)
            let dbModel = try await repository.revisionItems(for: userId, request: request)
            return RevisionMapper.map(dbModel)
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func item(for userId: UUID, itemID: UUID) async throws -> RevisionItemResponseDTO? {
        do {
            if let dbItem = try await repository.get(itemID: itemID, for: userId) {
                return RevisionMapper.map(dbItem, nextRevision: nil)
            }
            
            return nil
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func create(_ item: RevisionItemCreateRequestDTO, userID: UUID) async throws -> RevisionItemResponseDTO {
        let dbItem = RevisionMapper.map(item, userID: userID)
        let item = try await repository.create(dbItem, for: userID)
        let dto = RevisionMapper.map(item, nextRevision: nil)
        return dto
    }
    
    func update(item: RevisionItemPatchRequestDTO, userID: UUID) async throws -> RevisionItemResponseDTO {
        let dbItem = RevisionMapper.map(item, userID: userID)
        let updatedItem = try await repository.update(dbItem, for: userID)
        let dto = RevisionMapper.map(updatedItem, nextRevision: nil)
        return dto
    }
    
    func review(itemID: UUID, rating: InputRating, userID: UUID) async throws {
        let dbItem = try await repository.get(itemID: itemID, for: userID)
        
        guard let dbItem else {
            throw RevisionServiceError.itemNotFound(itemID, userID)
        }
        
        let retention = try await getRetentionRate(using: userID)
        let scheduler = MemoryScheduler(retention: retention)
        
        let newMemoryState = try scheduler.review(state: dbItem.memoryState, rating: rating)
        
        dbItem.memoryState = newMemoryState
        
        try await repository.save(dbItem)
    }
    
    func delete(itemID: UUID, userID: UUID) async throws {
        try await repository.delete(itemID: itemID, for: userID)
    }
}

// MARK: - Private
extension RevisionService {
    
    private func getRetentionRate(using userId: UUID) async throws -> Double? {
        try await userRepository.user(id: userId)?.settings.retentionRate
    }
}

private struct MemoryScheduler {
    
    private let fsrs: FSRS
    
    init(retention: Double?) {
        let userRetention = retention ?? FSRSConfigs.defaultRetention
        self.fsrs = FSRS(parameters: FSRSParameters(requestRetention: userRetention))
    }
    
    func nextRevision(of state: MemoryState) throws -> NextRevision {
        let card = self.createCard(using: state)
        let preview = try fsrs.repeat(card: card, now: .now)
        return nextRevision(using: preview)
    }
    
    func review(state: MemoryState, rating inputRating: InputRating) throws -> MemoryState {
        
        let rating = Rating(rawValue: inputRating.fsrsValue)!
        
        let card = createCard(using: state)
        
        let result = try fsrs.next(card: card, now: .now, grade: rating)
        let resultCard = result.card
        
        return MemoryState(
            due: resultCard.due,
            stability: resultCard.stability,
            difficulty: resultCard.difficulty,
            reps: resultCard.reps,
            lapses: resultCard.lapses,
            state: MemoryState.CardState(rawValue: resultCard.state.stringValue)!,
            lastReview: resultCard.lastReview
        )
    }
    
    private func nextRevision(using preview: IPreview) -> NextRevision {

        let easyDate = preview[Rating.easy]!.card.due
        let goodDate = preview[Rating.good]!.card.due
        let hardDate = preview[Rating.hard]!.card.due
        let againDate = preview[Rating.again]!.card.due
        
        return NextRevision(
            easy: easyDate,
            good: goodDate,
            hard: hardDate,
            again: againDate
        )
    }
    
    private func elapsedDays(since lastReview: Date?) -> Double {
        guard let lastReview else { return 0 }
        
        // 1 day = 86_400 seconds
        return Date().timeIntervalSince(lastReview) / TimeConstants.secondsPerDay
    }
    
    private func scheduledDays(due: Date, lastReview: Date?) -> Double {
        guard let lastReview else { return .zero }
        
        return due.timeIntervalSince(lastReview) / TimeConstants.secondsPerDay
    }
    
    private func createCard(using memoryState: MemoryState) -> Card {
        
        let elapsedDays = self.elapsedDays(since: memoryState.lastReview)
        
        let scheduledDays = self.scheduledDays(
            due: memoryState.due,
            lastReview: memoryState.lastReview
        )
        
        let cardState = CardState(rawValue: memoryState.state.fsrsValue)!
        
        let card = Card(
            due: memoryState.due,
            stability: memoryState.stability,
            difficulty: memoryState.difficulty,
            elapsedDays: elapsedDays,
            scheduledDays: scheduledDays,
            reps: memoryState.reps,
            lapses: memoryState.lapses,
            state: cardState,
            lastReview: memoryState.lastReview
        )
        
        return card
    }
}
