import SwiftUI
import SwiftData

struct AddEditWordView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let deck: Deck?
    let word: Word?

    @State private var term: String
    @State private var definition: String
    @State private var exampleSentence: String
    @State private var pronunciationGuide: String
    @State private var notes: String

    init(modelContext: ModelContext, deck: Deck?, word: Word? = nil) {
        self.modelContext = modelContext
        self.deck = deck
        self.word = word
        _term = State(initialValue: word?.term ?? "")
        _definition = State(initialValue: word?.definition ?? "")
        _exampleSentence = State(initialValue: word?.exampleSentence ?? "")
        _pronunciationGuide = State(initialValue: word?.pronunciationGuide ?? "")
        _notes = State(initialValue: word?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Word") {
                    TextField("Term", text: $term)
                        .autocorrectionDisabled()

                    TextField("Pronunciation Guide (Optional)", text: $pronunciationGuide)
                        .autocorrectionDisabled()
                        .font(.caption)
                }

                Section("Definition") {
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Example Sentence (Optional)") {
                    TextField("Example sentence using this word", text: $exampleSentence, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Notes (Optional)") {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }

                if let word = word {
                    Section("Progress") {
                        LabeledContent("Mastery Level") {
                            MasteryBadge(level: word.masteryLevel)
                        }

                        LabeledContent("Total Reviews") {
                            Text("\(word.totalReviews)")
                        }

                        LabeledContent("Accuracy") {
                            Text(String(format: "%.1f%%", word.masteryPercentage))
                        }

                        if let nextReview = word.nextReviewDate {
                            LabeledContent("Next Review") {
                                Text(nextReview, style: .relative)
                            }
                        }
                    }
                }
            }
            .navigationTitle(word == nil ? "New Word" : "Edit Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(word == nil ? "Add" : "Save") {
                        saveWord()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !term.trimmingCharacters(in: .whitespaces).isEmpty &&
        !definition.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveWord() {
        if let word = word {
            word.term = term
            word.definition = definition
            word.exampleSentence = exampleSentence
            word.pronunciationGuide = pronunciationGuide
            word.notes = notes
            if let deck = word.deck {
                deck.lastModified = Date()
            }
        } else {
            let newWord = Word(
                term: term,
                definition: definition,
                exampleSentence: exampleSentence,
                pronunciationGuide: pronunciationGuide,
                notes: notes,
                deck: deck
            )
            modelContext.insert(newWord)
            if let deck = deck {
                deck.words.append(newWord)
                deck.lastModified = Date()
            }
        }
    }
}

#Preview {
    AddEditWordView(
        modelContext: ModelContext(try! ModelContainer(for: Word.self)),
        deck: nil
    )
}
