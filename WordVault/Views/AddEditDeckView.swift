import SwiftUI
import SwiftData

struct AddEditDeckView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let deck: Deck?

    @State private var name: String
    @State private var description: String
    @State private var selectedColor: String

    let availableColors = [
        "#007AFF", "#5856D6", "#AF52DE", "#FF2D55",
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#00C7BE", "#30B0C7", "#32ADE6", "#5AC8FA"
    ]

    init(modelContext: ModelContext, deck: Deck? = nil) {
        self.modelContext = modelContext
        self.deck = deck
        _name = State(initialValue: deck?.name ?? "")
        _description = State(initialValue: deck?.deckDescription ?? "")
        _selectedColor = State(initialValue: deck?.colorHex ?? "#007AFF")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Information") {
                    TextField("Deck Name", text: $name)

                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Deck Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .blue)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(deck == nil ? "New Deck" : "Edit Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(deck == nil ? "Create" : "Save") {
                        saveDeck()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveDeck() {
        if let deck = deck {
            deck.name = name
            deck.deckDescription = description
            deck.colorHex = selectedColor
            deck.lastModified = Date()
        } else {
            let newDeck = Deck(name: name, description: description, colorHex: selectedColor)
            modelContext.insert(newDeck)
        }
    }
}

#Preview {
    AddEditDeckView(modelContext: ModelContext(try! ModelContainer(for: Deck.self)))
}
