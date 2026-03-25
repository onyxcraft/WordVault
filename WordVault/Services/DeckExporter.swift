import Foundation
import SwiftData

class DeckExporter {

    enum ExportError: Error {
        case noWords
        case exportFailed
    }

    static func exportDeck(_ deck: Deck) throws -> URL {
        guard !deck.words.isEmpty else {
            throw ExportError.noWords
        }

        var csvString = "Term,Definition,Example Sentence,Pronunciation,Notes,Date Added,Mastery Level,Reviews,Accuracy\n"

        for word in deck.words {
            let fields = [
                escapeCSVField(word.term),
                escapeCSVField(word.definition),
                escapeCSVField(word.exampleSentence),
                escapeCSVField(word.pronunciationGuide),
                escapeCSVField(word.notes),
                formatDate(word.dateAdded),
                String(word.masteryLevel),
                String(word.totalReviews),
                String(format: "%.1f%%", word.masteryPercentage)
            ]
            csvString += fields.joined(separator: ",") + "\n"
        }

        let fileName = "\(deck.name.replacingOccurrences(of: " ", with: "_"))_\(dateString()).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            throw ExportError.exportFailed
        }
    }

    private static func escapeCSVField(_ field: String) -> String {
        let needsQuotes = field.contains(",") || field.contains("\"") || field.contains("\n")
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return needsQuotes ? "\"\(escaped)\"" : escaped
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
