# Changelog

All notable changes to WordVault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-03-25

### Added
- Initial release of WordVault
- Word management with definition, example sentence, pronunciation guide, and notes
- Multiple deck/collection support with custom colors
- SM-2 spaced repetition algorithm for intelligent review scheduling
- Flashcard review mode with smooth 3D flip animation
- Quiz mode with multiple choice and fill-in-the-blank options
- 6-level mastery system (New → Learning → Familiar → Comfortable → Proficient → Mastered)
- Progress tracking with detailed statistics
- Review session history with accuracy and duration tracking
- CSV import functionality for bulk word addition
- Deck export with progress data
- Powerful search across all vocabulary
- Home screen widget showing word of the day (small, medium, and large sizes)
- Daily review reminder push notifications
- Dark mode support
- iPad optimization
- SwiftUI-based interface with MVVM architecture
- SwiftData for local persistence
- App group container for widget data sharing

### Features by Category

#### Word Management
- Add/edit/delete words
- Rich word information (term, definition, example, pronunciation, notes)
- Word assignment to decks
- Automatic date tracking

#### Study & Review
- Flashcard mode with flip animation
- Multiple choice quiz mode
- Fill-in-the-blank quiz mode
- Smart scheduling based on SM-2 algorithm
- Quality-based feedback (0-5 scale)
- Review session tracking

#### Organization
- Create/edit/delete decks
- Color-coded decks
- Deck descriptions
- Word count and due count per deck

#### Progress & Analytics
- Overall statistics dashboard
- Mastery level distribution
- Session history
- Accuracy tracking
- Study time tracking
- Per-word progress metrics

#### Data Management
- CSV import with custom format
- Deck export to CSV
- SwiftData persistence
- App group sharing

#### User Experience
- Home screen with quick stats
- Search functionality
- Settings panel
- Daily reminders
- Widget support (3 sizes)
- Dark mode
- iPad support

### Technical
- Built with SwiftUI and Swift 5.0
- Minimum iOS version: 17.0
- MVVM architecture
- SwiftData for persistence
- WidgetKit for home screen widgets
- UserNotifications for reminders
- No external dependencies

---

## Future Considerations

### Potential Features
- iCloud sync across devices
- Multiple language support
- Audio pronunciation
- Study streaks and achievements
- Custom themes
- Export to other formats (JSON, Anki)
- Import from dictionary APIs
- Collaborative decks
- Apple Watch app
- Today widget for quick reviews
