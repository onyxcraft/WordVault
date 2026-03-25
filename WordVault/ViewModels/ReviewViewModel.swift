import Foundation
import SwiftData
import SwiftUI

@MainActor
class ReviewViewModel: ObservableObject {
    @Published var currentWordIndex = 0
    @Published var showingAnswer = false
    @Published var sessionStartTime: Date?
    @Published var correctCount = 0
    @Published var reviewedCount = 0
    @Published var sessionComplete = false

    private var modelContext: ModelContext
    private(set) var words: [Word] = []
    private var deck: Deck?

    init(modelContext: ModelContext, words: [Word], deck: Deck?) {
        self.modelContext = modelContext
        self.words = words.shuffled()
        self.deck = deck
    }

    var currentWord: Word? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(reviewedCount) / Double(words.count)
    }

    var hasMoreWords: Bool {
        currentWordIndex < words.count
    }

    func startSession() {
        sessionStartTime = Date()
        currentWordIndex = 0
        showingAnswer = false
        correctCount = 0
        reviewedCount = 0
        sessionComplete = false
    }

    func toggleAnswer() {
        showingAnswer.toggle()
    }

    func recordAnswer(quality: Int) {
        guard let word = currentWord else { return }

        SpacedRepetition.updateWord(word, quality: quality)

        if quality >= 3 {
            correctCount += 1
        }

        reviewedCount += 1
        saveContext()

        moveToNextWord()
    }

    func moveToNextWord() {
        showingAnswer = false
        currentWordIndex += 1

        if currentWordIndex >= words.count {
            endSession()
        }
    }

    func skipWord() {
        moveToNextWord()
    }

    private func endSession() {
        sessionComplete = true

        guard let startTime = sessionStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)

        let session = ReviewSession(
            duration: duration,
            wordsReviewed: reviewedCount,
            correctAnswers: correctCount,
            deckName: deck?.name ?? "All Decks",
            sessionType: "flashcard"
        )

        modelContext.insert(session)
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func restartSession() {
        startSession()
    }
}
