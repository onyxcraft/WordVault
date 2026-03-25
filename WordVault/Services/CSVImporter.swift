import Foundation
import SwiftData

class CSVImporter {

    enum ImportError: Error {
        case invalidFormat
        case fileReadError
        case parseError(line: Int)
    }

    static func importWords(from url: URL, into deck: Deck, modelContext: ModelContext) throws -> Int {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.fileReadError
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let csvString = try String(contentsOf: url, encoding: .utf8)
        let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }

        guard lines.count > 1 else {
            throw ImportError.invalidFormat
        }

        var importedCount = 0

        // Skip header row (index 0)
        for (index, line) in lines.enumerated() where index > 0 {
            let fields = parseCSVLine(line)

            guard fields.count >= 2 else {
                throw ImportError.parseError(line: index + 1)
            }

            let term = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let definition = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let exampleSentence = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let pronunciation = fields.count > 3 ? fields[3].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let notes = fields.count > 4 ? fields[4].trimmingCharacters(in: .whitespacesAndNewlines) : ""

            let word = Word(
                term: term,
                definition: definition,
                exampleSentence: exampleSentence,
                pronunciationGuide: pronunciation,
                notes: notes,
                deck: deck
            )

            modelContext.insert(word)
            deck.words.append(word)
            importedCount += 1
        }

        deck.lastModified = Date()

        return importedCount
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        fields.append(currentField)

        return fields.map { $0.replacingOccurrences(of: "\"\"", with: "\"") }
    }

    static func getCSVTemplate() -> String {
        return "Term,Definition,Example Sentence,Pronunciation,Notes\nubiquitous,present everywhere,\"Smartphones have become ubiquitous in modern society.\",yoo-BIK-wi-tuhs,Common in formal writing"
    }
}
