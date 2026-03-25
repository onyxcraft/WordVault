import Foundation
import SwiftData

@Model
final class Deck {
    var id: UUID
    var name: String
    var deckDescription: String
    var colorHex: String
    var dateCreated: Date
    var lastModified: Date

    @Relationship(deleteRule: .cascade)
    var words: [Word]

    init(
        name: String,
        description: String = "",
        colorHex: String = "#007AFF"
    ) {
        self.id = UUID()
        self.name = name
        self.deckDescription = description
        self.colorHex = colorHex
        self.dateCreated = Date()
        self.lastModified = Date()
        self.words = []
    }

    var wordCount: Int {
        words.count
    }

    var dueForReviewCount: Int {
        words.filter { $0.isDueForReview }.count
    }

    var masteredWordsCount: Int {
        words.filter { $0.masteryLevel >= 5 }.count
    }

    var averageMastery: Double {
        guard !words.isEmpty else { return 0.0 }
        let total = words.reduce(0.0) { $0 + $1.masteryPercentage }
        return total / Double(words.count)
    }
}
