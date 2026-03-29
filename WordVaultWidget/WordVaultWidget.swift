import WidgetKit
import SwiftUI
import SwiftData

// Local helper to avoid depending on main app target's SpacedRepetition
private enum SpacedRepetition {
    static func getMasteryLabel(_ level: Int) -> String {
        switch level {
        case 0: return "New"
        case 1: return "Learning"
        case 2: return "Familiar"
        case 3: return "Comfortable"
        case 4: return "Proficient"
        case 5: return "Mastered"
        default: return "Unknown"
        }
    }
}

struct Provider: TimelineProvider {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Word.self,
            Deck.self,
            ReviewSession.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.lopodragon.wordvault")
        )

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func placeholder(in context: Context) -> WordEntry {
        WordEntry(
            date: Date(),
            word: Word(
                term: "Ubiquitous",
                definition: "Present, appearing, or found everywhere",
                exampleSentence: "Smartphones have become ubiquitous in modern society.",
                pronunciationGuide: "yoo-BIK-wi-tuhs"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> ()) {
        let entry = WordEntry(
            date: Date(),
            word: getWordOfTheDay() ?? Word(
                term: "Ephemeral",
                definition: "Lasting for a very short time",
                exampleSentence: "The beauty of cherry blossoms is ephemeral.",
                pronunciationGuide: "ih-FEM-er-uhl"
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!

        let word = getWordOfTheDay() ?? Word(
            term: "Serendipity",
            definition: "The occurrence of events by chance in a happy way",
            exampleSentence: "Finding that book was pure serendipity.",
            pronunciationGuide: "ser-uhn-DIP-i-tee"
        )

        let entry = WordEntry(date: currentDate, word: word)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func getWordOfTheDay() -> Word? {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Word>()

        do {
            let words = try context.fetch(descriptor)
            guard !words.isEmpty else { return nil }

            let calendar = Calendar.current
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let index = dayOfYear % words.count

            return words[index]
        } catch {
            print("Failed to fetch words: \(error)")
            return nil
        }
    }
}

struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word
}

struct WordVaultWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(word: entry.word)
        case .systemMedium:
            MediumWidgetView(word: entry.word)
        case .systemLarge:
            LargeWidgetView(word: entry.word)
        default:
            SmallWidgetView(word: entry.word)
        }
    }
}

struct SmallWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text("Word of the Day")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(word.term)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(word.definition)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct MediumWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Word of the Day")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(word.term)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    if !word.pronunciationGuide.isEmpty {
                        Text(word.pronunciationGuide)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "book.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.3))
            }

            Text(word.definition)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(2)

            if !word.exampleSentence.isEmpty {
                Text("\"\(word.exampleSentence)\"")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct LargeWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Word of the Day")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(word.term)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)

                    if !word.pronunciationGuide.isEmpty {
                        Text(word.pronunciationGuide)
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "book.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.3))
            }

            Divider()
                .background(.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 12) {
                Text("Definition")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))

                Text(word.definition)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
            }

            if !word.exampleSentence.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))

                    Text("\"\(word.exampleSentence)\"")
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(3)
                }
            }

            Spacer()

            HStack {
                if word.totalReviews > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                        Text("\(word.totalReviews)")
                    }
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Text("Mastery: \(SpacedRepetition.getMasteryLabel(word.masteryLevel))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct WordVaultWidget: Widget {
    let kind: String = "WordVaultWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordVaultWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new word every day from your vocabulary.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    WordVaultWidget()
} timeline: {
    WordEntry(
        date: .now,
        word: Word(
            term: "Ubiquitous",
            definition: "Present everywhere",
            exampleSentence: "Smartphones are ubiquitous."
        )
    )
}
