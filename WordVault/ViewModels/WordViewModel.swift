import Foundation
import SwiftData
import SwiftUI

@MainActor
class WordViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var selectedWord: Word?
    @Published var searchText = ""

    private var modelContext: ModelContext
    private var deck: Deck?

    init(modelContext: ModelContext, deck: Deck? = nil) {
        self.modelContext = modelContext
        self.deck = deck
        loadWords()
    }

    func loadWords() {
        if let deck = deck {
            words = deck.words
        } else {
            let descriptor = FetchDescriptor<Word>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
            do {
                words = try modelContext.fetch(descriptor)
            } catch {
                print("Failed to fetch words: \(error)")
            }
        }
    }

    var filteredWords: [Word] {
        if searchText.isEmpty {
            return words
        } else {
            return words.filter {
                $0.term.localizedCaseInsensitiveContains(searchText) ||
                $0.definition.localizedCaseInsensitiveContains(searchText) ||
                $0.exampleSentence.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func addWord(term: String, definition: String, exampleSentence: String, pronunciationGuide: String, notes: String, to deck: Deck?) {
        let word = Word(
            term: term,
            definition: definition,
            exampleSentence: exampleSentence,
            pronunciationGuide: pronunciationGuide,
            notes: notes,
            deck: deck
        )
        modelContext.insert(word)

        if let deck = deck {
            deck.words.append(word)
            deck.lastModified = Date()
        }

        saveContext()
        loadWords()
    }

    func updateWord(_ word: Word, term: String, definition: String, exampleSentence: String, pronunciationGuide: String, notes: String) {
        word.term = term
        word.definition = definition
        word.exampleSentence = exampleSentence
        word.pronunciationGuide = pronunciationGuide
        word.notes = notes

        if let deck = word.deck {
            deck.lastModified = Date()
        }

        saveContext()
        loadWords()
    }

    func deleteWord(_ word: Word) {
        if let deck = word.deck {
            deck.lastModified = Date()
        }
        modelContext.delete(word)
        saveContext()
        loadWords()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func getDueWords() -> [Word] {
        words.filter { $0.isDueForReview }
    }
}
