import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    let deck: Deck

    @State private var showingAddWord = false
    @State private var selectedWord: Word?
    @State private var showingImport = false
    @State private var showingExport = false
    @State private var showingReview = false
    @State private var showingQuiz = false
    @State private var searchText = ""
    @State private var exportURL: URL?
    @State private var showingShareSheet = false

    var filteredWords: [Word] {
        if searchText.isEmpty {
            return deck.words.sorted { $0.dateAdded > $1.dateAdded }
        } else {
            return deck.words.filter {
                $0.term.localizedCaseInsensitiveContains(searchText) ||
                $0.definition.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateAdded > $1.dateAdded }
        }
    }

    var dueWords: [Word] {
        deck.words.filter { $0.isDueForReview }
    }

    var body: some View {
        Group {
            if deck.words.isEmpty {
                emptyStateView
            } else {
                wordList
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search words")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingAddWord = true }) {
                        Label("Add Word", systemImage: "plus")
                    }

                    Button(action: { showingImport = true }) {
                        Label("Import CSV", systemImage: "square.and.arrow.down")
                    }

                    Button(action: { exportDeck() }) {
                        Label("Export Deck", systemImage: "square.and.arrow.up")
                    }
                    .disabled(deck.words.isEmpty)

                    Divider()

                    Button(action: { showingReview = true }) {
                        Label("Flashcard Review", systemImage: "rectangle.portrait.on.rectangle.portrait")
                    }
                    .disabled(dueWords.isEmpty)

                    Button(action: { showingQuiz = true }) {
                        Label("Quiz Mode", systemImage: "questionmark.circle")
                    }
                    .disabled(deck.words.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddWord) {
            AddEditWordView(modelContext: modelContext, deck: deck)
        }
        .sheet(item: $selectedWord) { word in
            AddEditWordView(modelContext: modelContext, deck: deck, word: word)
        }
        .sheet(isPresented: $showingReview) {
            if !dueWords.isEmpty {
                FlashcardView(words: dueWords, deck: deck)
            }
        }
        .sheet(isPresented: $showingQuiz) {
            QuizView(words: deck.words, deck: deck)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(isPresented: $showingImport, allowedContentTypes: [.commaSeparatedText]) { result in
            handleImport(result)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Words Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add your first word to this deck")
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(action: { showingAddWord = true }) {
                    Label("Add Word", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: { showingImport = true }) {
                    Label("Import CSV", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
    }

    private var wordList: some View {
        List {
            if !dueWords.isEmpty {
                Section {
                    Button(action: { showingReview = true }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.orange)
                            Text("\(dueWords.count) words due for review")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                ForEach(filteredWords) { word in
                    Button(action: { selectedWord = word }) {
                        WordListRow(word: word)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteWord(word)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            selectedWord = word
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            } header: {
                Text("Words (\(filteredWords.count))")
            }
        }
        .listStyle(.insetGrouped)
    }

    private func deleteWord(_ word: Word) {
        modelContext.delete(word)
        deck.lastModified = Date()
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let count = try CSVImporter.importWords(from: url, into: deck, modelContext: modelContext)
                print("Imported \(count) words")
            } catch {
                print("Import failed: \(error)")
            }
        case .failure(let error):
            print("File selection failed: \(error)")
        }
    }

    private func exportDeck() {
        do {
            let url = try DeckExporter.exportDeck(deck)
            exportURL = url
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }
}

struct WordListRow: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.term)
                    .font(.headline)

                Spacer()

                MasteryBadge(level: word.masteryLevel)
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
                if word.isDueForReview {
                    Label("Due", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if word.totalReviews > 0 {
                    Label("\(word.totalReviews) reviews", systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct MasteryBadge: View {
    let level: Int

    var body: some View {
        Text(SpacedRepetition.getMasteryLabel(level))
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: SpacedRepetition.getMasteryColor(level)))
            .clipShape(Capsule())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension UTType {
    static var commaSeparatedText: UTType {
        UTType(importedAs: "public.comma-separated-values-text")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Deck.self, Word.self, configurations: config)
    let deck = Deck(name: "Sample Deck")
    container.mainContext.insert(deck)

    return NavigationStack {
        WordListView(deck: deck)
            .modelContainer(container)
    }
}
