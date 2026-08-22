//
//  MemoryScheduler.swift
//  RevisorVapor
//
//  Created by Arun on 22/08/26.
//

import FSRS
import Foundation

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

struct MemoryScheduler {
    
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
