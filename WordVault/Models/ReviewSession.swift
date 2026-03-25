import Foundation
import SwiftData

@Model
final class ReviewSession {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var wordsReviewed: Int
    var correctAnswers: Int
    var deckName: String
    var sessionType: String

    init(
        duration: TimeInterval,
        wordsReviewed: Int,
        correctAnswers: Int,
        deckName: String,
        sessionType: String = "flashcard"
    ) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.wordsReviewed = wordsReviewed
        self.correctAnswers = correctAnswers
        self.deckName = deckName
        self.sessionType = sessionType
    }

    var accuracy: Double {
        guard wordsReviewed > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(wordsReviewed) * 100.0
    }
}
