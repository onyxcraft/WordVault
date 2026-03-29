import SwiftUI
import SwiftData

struct FlashcardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let words: [Word]
    let deck: Deck?

    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @State private var rotation: Double = 0
    @State private var sessionStartTime = Date()
    @State private var correctCount = 0
    @State private var reviewedCount = 0
    @State private var sessionComplete = false

    @State private var shuffledWords: [Word] = []

    var currentWord: Word? {
        guard currentIndex < shuffledWords.count else { return nil }
        return shuffledWords[currentIndex]
    }

    var progress: Double {
        guard !shuffledWords.isEmpty else { return 0 }
        return Double(reviewedCount) / Double(shuffledWords.count)
    }

    var body: some View {
        NavigationStack {
            if sessionComplete {
                sessionSummary
            } else {
                reviewContent
            }
        }
        .onAppear {
            shuffledWords = words.shuffled()
        }
    }

    private var reviewContent: some View {
        VStack(spacing: 20) {
            progressBar

            if let word = currentWord {
                flashcard(for: word)
            }

            controlButtons
        }
        .padding()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .tint(Color.accentColor)

            HStack {
                Text("\(reviewedCount) / \(shuffledWords.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func flashcard(for word: Word) -> some View {
        ZStack {
            CardFace(isVisible: !showingAnswer) {
                VStack(spacing: 16) {
                    Text("TERM")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(word.term)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)

                    if !word.pronunciationGuide.isEmpty {
                        Text(word.pronunciationGuide)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }

                    Spacer()

                    Text("Tap to reveal definition")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            CardFace(isVisible: showingAnswer) {
                VStack(spacing: 16) {
                    Text("DEFINITION")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(word.definition)
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    if !word.exampleSentence.isEmpty {
                        Divider()
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            Text("EXAMPLE")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Text(word.exampleSentence)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .italic()
                        }
                    }

                    Spacer()

                    Text("How well did you know this?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxHeight: 400)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            flipCard()
        }
    }

    private var controlButtons: some View {
        VStack(spacing: 16) {
            if showingAnswer {
                VStack(spacing: 12) {
                    Text("Rate your recall:")
                        .font(.headline)

                    HStack(spacing: 12) {
                        QualityButton(title: "Again", color: .red, quality: 0, action: recordAnswer)
                        QualityButton(title: "Hard", color: .orange, quality: 2, action: recordAnswer)
                        QualityButton(title: "Good", color: .blue, quality: 4, action: recordAnswer)
                        QualityButton(title: "Easy", color: .green, quality: 5, action: recordAnswer)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Button(action: flipCard) {
                    Text("Show Answer")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .animation(.easeInOut, value: showingAnswer)
    }

    private var sessionSummary: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Session Complete!")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                SummaryRow(label: "Words Reviewed", value: "\(reviewedCount)")
                SummaryRow(label: "Correct", value: "\(correctCount)")
                SummaryRow(label: "Accuracy", value: String(format: "%.1f%%", accuracy))
                SummaryRow(label: "Duration", value: durationString)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .navigationBarBackButtonHidden()
    }

    private var accuracy: Double {
        guard reviewedCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewedCount) * 100
    }

    private var durationString: String {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotation += 180
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showingAnswer.toggle()
        }
    }

    private func recordAnswer(quality: Int) {
        guard let word = currentWord else { return }

        SpacedRepetition.updateWord(word, quality: quality)

        if quality >= 3 {
            correctCount += 1
        }

        reviewedCount += 1

        moveToNextWord()
    }

    private func moveToNextWord() {
        showingAnswer = false
        rotation = 0
        currentIndex += 1

        if currentIndex >= shuffledWords.count {
            endSession()
        }
    }

    private func endSession() {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let session = ReviewSession(
            duration: duration,
            wordsReviewed: reviewedCount,
            correctAnswers: correctCount,
            deckName: deck?.name ?? "All Decks",
            sessionType: "flashcard"
        )
        modelContext.insert(session)
        sessionComplete = true
    }
}

struct CardFace<Content: View>: View {
    let isVisible: Bool
    @ViewBuilder let content: Content

    var body: some View {
        if isVisible {
            VStack {
                content
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }
}

struct QualityButton: View {
    let title: String
    let color: Color
    let quality: Int
    let action: (Int) -> Void

    var body: some View {
        Button(action: { action(quality) }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Word.self, Deck.self, configurations: config)
    let deck = Deck(name: "Test")
    let word = Word(term: "Ubiquitous", definition: "Present everywhere", deck: deck)
    container.mainContext.insert(word)

    return FlashcardView(words: [word], deck: deck)
        .modelContainer(container)
}
