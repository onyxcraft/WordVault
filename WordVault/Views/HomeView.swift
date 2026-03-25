import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [Deck]
    @Query private var words: [Word]

    @State private var showingReview = false
    @State private var selectedDeck: Deck?

    var dueWords: [Word] {
        words.filter { $0.isDueForReview }
    }

    var totalWords: Int {
        words.count
    }

    var masteredWords: Int {
        words.filter { $0.masteryLevel >= 5 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    statsGrid
                    quickActionsSection
                    recentDecksSection
                }
                .padding()
            }
            .navigationTitle("WordVault")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingReview) {
                if !dueWords.isEmpty {
                    FlashcardView(words: dueWords, deck: selectedDeck)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ready to Review")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dueWords.count)")
                        .font(.system(size: 48, weight: .bold))
                    Text("words due")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: {
                    selectedDeck = nil
                    showingReview = true
                }) {
                    Label("Start Review", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(dueWords.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Total Words", value: "\(totalWords)", icon: "books.vertical.fill", color: .blue)
            StatCard(title: "Mastered", value: "\(masteredWords)", icon: "star.fill", color: .yellow)
            StatCard(title: "Decks", value: "\(decks.count)", icon: "square.stack.3d.up.fill", color: .purple)
            StatCard(title: "Accuracy", value: "\(Int(overallAccuracy))%", icon: "checkmark.circle.fill", color: .green)
        }
    }

    private var overallAccuracy: Double {
        guard !words.isEmpty else { return 0 }
        let total = words.reduce(0.0) { $0 + $1.masteryPercentage }
        return total / Double(words.count)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 12) {
                NavigationLink(destination: SearchView()) {
                    QuickActionRow(icon: "magnifyingglass", title: "Search Words", color: .orange)
                }

                NavigationLink(destination: DeckListView()) {
                    QuickActionRow(icon: "plus.square.fill", title: "Add Deck", color: .green)
                }
            }
        }
    }

    private var recentDecksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Decks")
                .font(.headline)

            if decks.isEmpty {
                EmptyDeckView()
            } else {
                ForEach(decks.prefix(3)) { deck in
                    NavigationLink(destination: WordListView(deck: deck)) {
                        DeckRowView(deck: deck)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DeckRowView: View {
    let deck: Deck

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: deck.colorHex) ?? .blue)
                .frame(width: 40, height: 40)
                .overlay {
                    Text("\(deck.wordCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)
                Text("\(deck.dueForReviewCount) due • \(deck.masteredWordsCount) mastered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyDeckView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No decks yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Create your first deck to start learning")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Word.self, Deck.self, ReviewSession.self], inMemory: true)
}
