import SwiftUI
import SwiftData

enum QuizMode: String, CaseIterable {
    case multipleChoice = "Multiple Choice"
    case fillInBlank = "Fill in the Blank"
}

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let words: [Word]
    let deck: Deck?

    @State private var quizMode: QuizMode = .multipleChoice
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var userAnswer: String = ""
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var correctCount = 0
    @State private var sessionStartTime = Date()
    @State private var sessionComplete = false
    @State private var shuffledWords: [Word] = []

    var currentWord: Word? {
        guard currentIndex < shuffledWords.count else { return nil }
        return shuffledWords[currentIndex]
    }

    var progress: Double {
        guard !shuffledWords.isEmpty else { return 0 }
        return Double(currentIndex) / Double(shuffledWords.count)
    }

    var body: some View {
        NavigationStack {
            if sessionComplete {
                summaryView
            } else {
                quizContent
            }
        }
        .onAppear {
            shuffledWords = words.shuffled()
        }
    }

    private var quizContent: some View {
        VStack(spacing: 24) {
            modePicker

            progressBar

            if let word = currentWord {
                questionCard(for: word)
            }

            answerSection

            if showingResult {
                resultFeedback
            }

            navigationButtons
        }
        .padding()
        .navigationTitle("Quiz Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private var modePicker: some View {
        Picker("Quiz Mode", selection: $quizMode) {
            ForEach(QuizMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .disabled(currentIndex > 0)
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .tint(.accentColor)

            HStack {
                Text("Question \(currentIndex + 1) / \(shuffledWords.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(correctCount) correct")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    private func questionCard(for word: Word) -> some View {
        VStack(spacing: 16) {
            Text("What is the definition of:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(word.term)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            if !word.pronunciationGuide.isEmpty {
                Text(word.pronunciationGuide)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var answerSection: some View {
        if let word = currentWord {
            switch quizMode {
            case .multipleChoice:
                multipleChoiceOptions(for: word)
            case .fillInBlank:
                fillInBlankField
            }
        }
    }

    private func multipleChoiceOptions(for word: Word) -> some View {
        VStack(spacing: 12) {
            ForEach(generateChoices(for: word), id: \.self) { choice in
                ChoiceButton(
                    text: choice,
                    isSelected: selectedAnswer == choice,
                    isCorrect: showingResult ? choice == word.definition : nil,
                    action: {
                        if !showingResult {
                            selectedAnswer = choice
                        }
                    }
                )
            }
        }
    }

    private var fillInBlankField: some View {
        VStack(spacing: 12) {
            TextField("Type your answer", text: $userAnswer)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .disabled(showingResult)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var resultFeedback: some View {
        HStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(isCorrect ? .green : .red)

            VStack(alignment: .leading, spacing: 4) {
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundStyle(isCorrect ? .green : .red)

                if !isCorrect, let word = currentWord {
                    Text("Answer: \(word.definition)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if showingResult {
                Button(action: moveToNext) {
                    Text(currentIndex < shuffledWords.count - 1 ? "Next" : "Finish")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Button(action: checkAnswer) {
                    Text("Check Answer")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? Color.accentColor : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSubmit)
            }
        }
    }

    private var canSubmit: Bool {
        switch quizMode {
        case .multipleChoice:
            return selectedAnswer != nil
        case .fillInBlank:
            return !userAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var summaryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Quiz Complete!")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                SummaryRow(label: "Questions", value: "\(shuffledWords.count)")
                SummaryRow(label: "Correct", value: "\(correctCount)")
                SummaryRow(label: "Score", value: String(format: "%.1f%%", score))
                SummaryRow(label: "Mode", value: quizMode.rawValue)
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

    private var score: Double {
        guard !shuffledWords.isEmpty else { return 0 }
        return Double(correctCount) / Double(shuffledWords.count) * 100
    }

    private func generateChoices(for word: Word) -> [String] {
        var choices = [word.definition]

        let otherWords = shuffledWords.filter { $0.id != word.id }.shuffled()
        let numChoices = min(3, otherWords.count)

        for i in 0..<numChoices {
            choices.append(otherWords[i].definition)
        }

        return choices.shuffled()
    }

    private func checkAnswer() {
        guard let word = currentWord else { return }

        switch quizMode {
        case .multipleChoice:
            isCorrect = selectedAnswer == word.definition
        case .fillInBlank:
            let normalized1 = word.definition.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized2 = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            isCorrect = normalized1 == normalized2
        }

        if isCorrect {
            correctCount += 1
            SpacedRepetition.updateWord(word, quality: 5)
        } else {
            SpacedRepetition.updateWord(word, quality: 1)
        }

        withAnimation {
            showingResult = true
        }
    }

    private func moveToNext() {
        currentIndex += 1
        selectedAnswer = nil
        userAnswer = ""
        showingResult = false
        isCorrect = false

        if currentIndex >= shuffledWords.count {
            endSession()
        }
    }

    private func endSession() {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let session = ReviewSession(
            duration: duration,
            wordsReviewed: shuffledWords.count,
            correctAnswers: correctCount,
            deckName: deck?.name ?? "All Decks",
            sessionType: quizMode.rawValue.lowercased()
        )
        modelContext.insert(session)
        sessionComplete = true
    }
}

struct ChoiceButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void

    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return .green.opacity(0.2)
            } else if isSelected {
                return .red.opacity(0.2)
            }
        } else if isSelected {
            return .accentColor.opacity(0.2)
        }
        return Color(.systemBackground)
    }

    var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : (isSelected ? .red : .gray.opacity(0.3))
        }
        return isSelected ? .accentColor : .gray.opacity(0.3)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : "circle"))
                        .foregroundStyle(isCorrect ? .green : (isSelected ? .red : .gray))
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentColor)
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Word.self, Deck.self, configurations: config)
    let deck = Deck(name: "Test")
    let word1 = Word(term: "Ubiquitous", definition: "Present everywhere", deck: deck)
    let word2 = Word(term: "Ephemeral", definition: "Lasting for a short time", deck: deck)
    container.mainContext.insert(word1)
    container.mainContext.insert(word2)

    return QuizView(words: [word1, word2], deck: deck)
        .modelContainer(container)
}
