import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]

    @State private var searchText = ""
    @State private var selectedWord: Word?
    @State private var searchScope: SearchScope = .all

    enum SearchScope: String, CaseIterable {
        case all = "All"
        case term = "Term"
        case definition = "Definition"
    }

    var filteredWords: [Word] {
        if searchText.isEmpty {
            return words.sorted { $0.dateAdded > $1.dateAdded }
        }

        return words.filter { word in
            switch searchScope {
            case .all:
                return word.term.localizedCaseInsensitiveContains(searchText) ||
                       word.definition.localizedCaseInsensitiveContains(searchText) ||
                       word.exampleSentence.localizedCaseInsensitiveContains(searchText) ||
                       word.notes.localizedCaseInsensitiveContains(searchText)
            case .term:
                return word.term.localizedCaseInsensitiveContains(searchText)
            case .definition:
                return word.definition.localizedCaseInsensitiveContains(searchText)
            }
        }.sorted { $0.dateAdded > $1.dateAdded }
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    emptySearchView
                } else if filteredWords.isEmpty {
                    noResultsView
                } else {
                    searchResults
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search words")
            .sheet(item: $selectedWord) { word in
                AddEditWordView(modelContext: modelContext, deck: word.deck, word: word)
            }
        }
    }

    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Search Your Vocabulary")
                .font(.title2)
                .fontWeight(.bold)

            Text("Search across all your words and decks")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Results")
                .font(.title2)
                .fontWeight(.bold)

            Text("Try a different search term")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var searchResults: some View {
        List {
            Section {
                Picker("Search in", selection: $searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                ForEach(filteredWords) { word in
                    Button(action: { selectedWord = word }) {
                        SearchResultRow(word: word, searchText: searchText)
                    }
                }
            } header: {
                Text("\(filteredWords.count) result\(filteredWords.count == 1 ? "" : "s")")
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct SearchResultRow: View {
    let word: Word
    let searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.term)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if let deck = word.deck {
                    Text(deck.name)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: deck.colorHex) ?? .blue)
                        .clipShape(Capsule())
                }
            }

            Text(word.definition)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !word.exampleSentence.isEmpty {
                Text(word.exampleSentence)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                MasteryBadge(level: word.masteryLevel)

                if word.totalReviews > 0 {
                    Label("\(word.totalReviews) reviews", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Word.self, Deck.self, ReviewSession.self], inMemory: true)
}
