import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deck.dateCreated, order: .reverse) private var decks: [Deck]

    @State private var showingAddDeck = false
    @State private var selectedDeck: Deck?
    @State private var showingEditDeck = false

    var body: some View {
        NavigationStack {
            Group {
                if decks.isEmpty {
                    emptyStateView
                } else {
                    deckList
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddDeck = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                AddEditDeckView(modelContext: modelContext)
            }
            .sheet(item: $selectedDeck) { deck in
                AddEditDeckView(modelContext: modelContext, deck: deck)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Decks Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Create your first deck to organize your vocabulary words")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { showingAddDeck = true }) {
                Label("Create Deck", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private var deckList: some View {
        List {
            ForEach(decks) { deck in
                NavigationLink(destination: WordListView(deck: deck)) {
                    DeckListRow(deck: deck)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteDeck(deck)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        selectedDeck = deck
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func deleteDeck(_ deck: Deck) {
        modelContext.delete(deck)
    }
}

struct DeckListRow: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: deck.colorHex) ?? .blue)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(deck.name)
                    .font(.headline)

                if !deck.deckDescription.isEmpty {
                    Text(deck.deckDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    Label("\(deck.wordCount)", systemImage: "book.fill")
                    Label("\(deck.dueForReviewCount)", systemImage: "clock.fill")
                    Label("\(deck.masteredWordsCount)", systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DeckListView()
        .modelContainer(for: [Word.self, Deck.self, ReviewSession.self], inMemory: true)
}
