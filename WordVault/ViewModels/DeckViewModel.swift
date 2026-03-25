import Foundation
import SwiftData
import SwiftUI

@MainActor
class DeckViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    @Published var selectedDeck: Deck?
    @Published var showingAddDeck = false
    @Published var showingImport = false
    @Published var importURL: URL?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDecks()
    }

    func loadDecks() {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        do {
            decks = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch decks: \(error)")
        }
    }

    func addDeck(name: String, description: String, colorHex: String) {
        let deck = Deck(name: name, description: description, colorHex: colorHex)
        modelContext.insert(deck)
        saveContext()
        loadDecks()
    }

    func updateDeck(_ deck: Deck, name: String, description: String, colorHex: String) {
        deck.name = name
        deck.deckDescription = description
        deck.colorHex = colorHex
        deck.lastModified = Date()
        saveContext()
    }

    func deleteDeck(_ deck: Deck) {
        modelContext.delete(deck)
        saveContext()
        loadDecks()
    }

    func importWords(from url: URL, into deck: Deck) -> Result<Int, Error> {
        do {
            let count = try CSVImporter.importWords(from: url, into: deck, modelContext: modelContext)
            saveContext()
            loadDecks()
            return .success(count)
        } catch {
            return .failure(error)
        }
    }

    func exportDeck(_ deck: Deck) -> Result<URL, Error> {
        do {
            let url = try DeckExporter.exportDeck(deck)
            return .success(url)
        } catch {
            return .failure(error)
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func getDueWords(for deck: Deck) -> [Word] {
        deck.words.filter { $0.isDueForReview }
    }

    func getTotalDueWords() -> Int {
        decks.reduce(0) { $0 + $1.dueForReviewCount }
    }
}
