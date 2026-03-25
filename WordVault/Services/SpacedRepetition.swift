import Foundation

class SpacedRepetition {

    // SM-2 Algorithm Implementation
    // Quality: 0-5 where:
    // 5: perfect response
    // 4: correct response after hesitation
    // 3: correct response with difficulty
    // 2: incorrect but remembered
    // 1: incorrect, familiar
    // 0: complete blackout

    static func updateWord(_ word: Word, quality: Int) {
        let q = max(0, min(5, quality))

        word.totalReviews += 1
        if q >= 3 {
            word.correctReviews += 1
            word.consecutiveCorrect += 1
        } else {
            word.consecutiveCorrect = 0
        }

        // Update mastery level based on consecutive correct answers
        updateMasteryLevel(word)

        // SM-2 Algorithm
        var newEF = word.easinessFactor + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02))

        // Ensure EF stays within bounds
        newEF = max(1.3, newEF)

        word.easinessFactor = newEF

        var newInterval: Int
        var newRepetition: Int

        if q < 3 {
            // Reset if quality is below 3
            newRepetition = 0
            newInterval = 1
        } else {
            if word.repetitionCount == 0 {
                newInterval = 1
            } else if word.repetitionCount == 1 {
                newInterval = 6
            } else {
                newInterval = Int(ceil(Double(word.intervalDays) * newEF))
            }
            newRepetition = word.repetitionCount + 1
        }

        word.repetitionCount = newRepetition
        word.intervalDays = newInterval
        word.lastReviewed = Date()
        word.nextReviewDate = Calendar.current.date(byAdding: .day, value: newInterval, to: Date())
    }

    private static func updateMasteryLevel(_ word: Word) {
        // Mastery levels: 0 (New) -> 1 (Learning) -> 2 (Familiar) -> 3 (Comfortable) -> 4 (Proficient) -> 5 (Mastered)
        switch word.consecutiveCorrect {
        case 0:
            word.masteryLevel = 0
        case 1...2:
            word.masteryLevel = 1
        case 3...5:
            word.masteryLevel = 2
        case 6...9:
            word.masteryLevel = 3
        case 10...14:
            word.masteryLevel = 4
        default:
            word.masteryLevel = 5
        }
    }

    static func getMasteryLabel(_ level: Int) -> String {
        switch level {
        case 0:
            return "New"
        case 1:
            return "Learning"
        case 2:
            return "Familiar"
        case 3:
            return "Comfortable"
        case 4:
            return "Proficient"
        case 5:
            return "Mastered"
        default:
            return "Unknown"
        }
    }

    static func getMasteryColor(_ level: Int) -> String {
        switch level {
        case 0:
            return "#8E8E93"
        case 1:
            return "#FF3B30"
        case 2:
            return "#FF9500"
        case 3:
            return "#FFCC00"
        case 4:
            return "#34C759"
        case 5:
            return "#007AFF"
        default:
            return "#8E8E93"
        }
    }
}
