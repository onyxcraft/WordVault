import Foundation
import SwiftData

@Model
final class Word {
    var id: UUID
    var term: String
    var definition: String
    var exampleSentence: String
    var pronunciationGuide: String
    var notes: String
    var dateAdded: Date
    var lastReviewed: Date?
    var nextReviewDate: Date?

    // SM-2 Algorithm properties
    var easinessFactor: Double
    var repetitionCount: Int
    var intervalDays: Int

    // Mastery tracking
    var masteryLevel: Int
    var consecutiveCorrect: Int
    var totalReviews: Int
    var correctReviews: Int

    @Relationship(inverse: \Deck.words)
    var deck: Deck?

    init(
        term: String,
        definition: String,
        exampleSentence: String = "",
        pronunciationGuide: String = "",
        notes: String = "",
        deck: Deck? = nil
    ) {
        self.id = UUID()
        self.term = term
        self.definition = definition
        self.exampleSentence = exampleSentence
        self.pronunciationGuide = pronunciationGuide
        self.notes = notes
        self.dateAdded = Date()
        self.lastReviewed = nil
        self.nextReviewDate = Date()

        // SM-2 initial values
        self.easinessFactor = 2.5
        self.repetitionCount = 0
        self.intervalDays = 0

        // Mastery initial values
        self.masteryLevel = 0
        self.consecutiveCorrect = 0
        self.totalReviews = 0
        self.correctReviews = 0

        self.deck = deck
    }

    var masteryPercentage: Double {
        guard totalReviews > 0 else { return 0.0 }
        return Double(correctReviews) / Double(totalReviews) * 100.0
    }

    var isDueForReview: Bool {
        guard let nextReview = nextReviewDate else { return true }
        return Date() >= nextReview
    }
}
