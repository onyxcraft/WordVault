# WordVault

**Build your vocabulary with intelligent spaced repetition**

WordVault is a comprehensive vocabulary builder and flashcard app for iOS 17+ that uses the SM-2 spaced repetition algorithm to help you master new words efficiently.

## Features

### Core Functionality
- **Word Management**: Add words with definitions, example sentences, pronunciation guides, and custom notes
- **Multiple Decks**: Organize your vocabulary into themed collections
- **Smart Reviews**: SM-2 spaced repetition algorithm optimizes your learning schedule
- **Mastery Tracking**: Monitor your progress with 6 mastery levels (New → Learning → Familiar → Comfortable → Proficient → Mastered)

### Study Modes
- **Flashcard Review**: Interactive cards with smooth flip animations
- **Quiz Mode**:
  - Multiple choice questions
  - Fill-in-the-blank exercises
- **Smart Scheduling**: Words are automatically scheduled for review based on your performance

### Data Management
- **CSV Import**: Bulk import words from CSV files
- **Deck Export**: Export your decks with progress data
- **Search**: Powerful search across all your vocabulary
- **Cloud Sync**: Data stored with SwiftData for persistence

### User Experience
- **Home Screen Widget**: Display a new word of the day every day
- **Daily Reminders**: Push notifications to keep your learning streak going
- **Progress Tracking**: Detailed statistics and session history
- **Dark Mode**: Full support for system appearance
- **iPad Support**: Optimized for both iPhone and iPad

## Technical Details

### Requirements
- iOS 17.0 or later
- iPhone and iPad compatible

### Architecture
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Persistence**: SwiftData
- **Widgets**: WidgetKit
- **Notifications**: UserNotifications
- **No External Dependencies**

### Bundle Information
- **Bundle ID**: com.lopodragon.wordvault
- **Price**: $3.99 USD (one-time purchase)
- **Category**: Education
- **Version**: 1.0

## Project Structure

```
WordVault/
├── WordVault/
│   ├── Models/
│   │   ├── Word.swift          # Word data model
│   │   ├── Deck.swift          # Deck/collection model
│   │   └── ReviewSession.swift # Session tracking model
│   ├── ViewModels/
│   │   ├── DeckViewModel.swift
│   │   ├── WordViewModel.swift
│   │   └── ReviewViewModel.swift
│   ├── Views/
│   │   ├── HomeView.swift
│   │   ├── DeckListView.swift
│   │   ├── WordListView.swift
│   │   ├── AddEditWordView.swift
│   │   ├── AddEditDeckView.swift
│   │   ├── FlashcardView.swift
│   │   ├── QuizView.swift
│   │   ├── ProgressView.swift
│   │   ├── SearchView.swift
│   │   └── SettingsView.swift
│   ├── Services/
│   │   ├── SpacedRepetition.swift    # SM-2 algorithm
│   │   ├── CSVImporter.swift
│   │   ├── DeckExporter.swift
│   │   └── NotificationManager.swift
│   ├── Assets.xcassets/
│   └── WordVaultApp.swift
├── WordVaultWidget/
│   ├── WordVaultWidget.swift
│   ├── WordVaultWidgetBundle.swift
│   └── Assets.xcassets/
└── WordVault.xcodeproj/
```

## Spaced Repetition Algorithm

WordVault uses the SuperMemo 2 (SM-2) algorithm for optimal review scheduling:

- **Quality Ratings**: 0-5 scale for each review
  - 5: Perfect response
  - 4: Correct after hesitation
  - 3: Correct with difficulty
  - 2: Incorrect but remembered
  - 1: Incorrect but familiar
  - 0: Complete blackout

- **Adaptive Intervals**: Review intervals automatically adjust based on your performance
- **Easiness Factor**: Each word has an individual easiness factor that evolves with reviews

## CSV Import Format

Import words using CSV files with the following format:

```csv
Term,Definition,Example Sentence,Pronunciation,Notes
ubiquitous,present everywhere,"Smartphones have become ubiquitous in modern society.",yoo-BIK-wi-tuhs,Common in formal writing
ephemeral,lasting for a short time,"The beauty of cherry blossoms is ephemeral.",ih-FEM-er-uhl,Often used in poetry
```

## Widget Configuration

The Word of the Day widget is available in three sizes:
- **Small**: Shows term and definition
- **Medium**: Includes pronunciation and example
- **Large**: Full word details with mastery status

The widget automatically updates daily at midnight with a new word from your collection.

## Building the Project

1. Open `WordVault.xcodeproj` in Xcode 15.0 or later
2. Select your development team in signing settings
3. Build and run on simulator or device

## License

MIT License - See LICENSE file for details

## Privacy

WordVault stores all data locally on your device using SwiftData. The app group container enables data sharing between the main app and the widget extension. No data is transmitted to external servers.

## Support

For issues, feature requests, or contributions, please visit the project repository.

---

**WordVault** - Master vocabulary through intelligent spaced repetition
