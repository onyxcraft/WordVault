import SwiftUI
import SwiftData
import Charts

struct WordProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReviewSession.date, order: .reverse) private var sessions: [ReviewSession]
    @Query private var words: [Word]
    @Query private var decks: [Deck]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    overallStatsSection
                    masteryDistributionSection
                    recentSessionsSection
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Statistics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ProgressStatCard(
                    title: "Total Words",
                    value: "\(words.count)",
                    icon: "book.fill",
                    color: .blue
                )

                ProgressStatCard(
                    title: "Total Reviews",
                    value: "\(totalReviews)",
                    icon: "repeat",
                    color: .purple
                )

                ProgressStatCard(
                    title: "Avg. Accuracy",
                    value: String(format: "%.0f%%", averageAccuracy),
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                ProgressStatCard(
                    title: "Study Time",
                    value: totalStudyTime,
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }

    private var masteryDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mastery Distribution")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(0...5, id: \.self) { level in
                    MasteryBar(
                        level: level,
                        count: masteryCount(for: level),
                        total: words.count
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Sessions")
                .font(.headline)

            if sessions.isEmpty {
                EmptySessionsView()
            } else {
                VStack(spacing: 12) {
                    ForEach(sessions.prefix(10)) { session in
                        SessionRow(session: session)
                    }
                }
            }
        }
    }

    private var totalReviews: Int {
        words.reduce(0) { $0 + $1.totalReviews }
    }

    private var averageAccuracy: Double {
        guard !words.isEmpty else { return 0 }
        let total = words.reduce(0.0) { $0 + $1.masteryPercentage }
        return total / Double(words.count)
    }

    private var totalStudyTime: String {
        let totalSeconds = sessions.reduce(0.0) { $0 + $1.duration }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func masteryCount(for level: Int) -> Int {
        words.filter { $0.masteryLevel == level }.count
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct MasteryBar: View {
    let level: Int
    let count: Int
    let total: Int

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(SpacedRepetition.getMasteryLabel(level))
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 90, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .clipShape(Capsule())

                    Rectangle()
                        .fill(Color(hex: SpacedRepetition.getMasteryColor(level)) ?? .blue)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 8)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct SessionRow: View {
    let session: ReviewSession

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(sessionColor)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: sessionIcon)
                        .foregroundStyle(.white)
                        .font(.caption)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.deckName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(session.wordsReviewed) words • \(Int(session.accuracy))% accuracy")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(session.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(session.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sessionColor: Color {
        switch session.sessionType.lowercased() {
        case "flashcard":
            return .blue
        case "multiple choice":
            return .purple
        case "fill in the blank":
            return .green
        default:
            return .gray
        }
    }

    private var sessionIcon: String {
        switch session.sessionType.lowercased() {
        case "flashcard":
            return "rectangle.portrait.on.rectangle.portrait"
        case "multiple choice":
            return "list.bullet"
        default:
            return "pencil"
        }
    }
}

struct EmptySessionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No sessions yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Start reviewing to see your progress")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    WordProgressView()
        .modelContainer(for: [Word.self, Deck.self, ReviewSession.self], inMemory: true)
}
