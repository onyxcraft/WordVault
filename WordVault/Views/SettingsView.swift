import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("defaultReviewCount") private var defaultReviewCount = 20

    @State private var showingReminderPicker = false

    var body: some View {
        NavigationStack {
            Form {
                notificationsSection
                reviewSettingsSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
        .task {
            await notificationManager.checkAuthorizationStatus()
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Daily Review Reminder", isOn: $dailyReminderEnabled)
                .onChange(of: dailyReminderEnabled) { _, newValue in
                    handleReminderToggle(newValue)
                }

            if dailyReminderEnabled {
                Button(action: { showingReminderPicker = true }) {
                    HStack {
                        Text("Reminder Time")
                        Spacer()
                        Text(reminderTimeString)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Get reminded to review your vocabulary daily")
        }
        .sheet(isPresented: $showingReminderPicker) {
            ReminderTimePicker(hour: $reminderHour, minute: $reminderMinute) {
                updateReminderTime()
            }
        }
    }

    private var reviewSettingsSection: some View {
        Section {
            Stepper("Default Review Count: \(defaultReviewCount)", value: $defaultReviewCount, in: 5...100, step: 5)
        } header: {
            Text("Review Settings")
        } footer: {
            Text("Number of words to review per session")
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "1.0")
            LabeledContent("Bundle ID", value: "com.lopodragon.wordvault")

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Text("GitHub Repository")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            Text("WordVault - Build your vocabulary with spaced repetition")
        }
    }

    private var reminderTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date())!
        return formatter.string(from: date)
    }

    private func handleReminderToggle(_ enabled: Bool) {
        Task {
            if enabled {
                if !notificationManager.isAuthorized {
                    await notificationManager.requestAuthorization()
                }

                if notificationManager.isAuthorized {
                    notificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                } else {
                    dailyReminderEnabled = false
                }
            } else {
                notificationManager.cancelDailyReminder()
            }
        }
    }

    private func updateReminderTime() {
        if dailyReminderEnabled {
            notificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        }
    }
}

struct ReminderTimePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hour: Int
    @Binding var minute: Int
    let onSave: () -> Void

    @State private var selectedDate: Date

    init(hour: Binding<Int>, minute: Binding<Int>, onSave: @escaping () -> Void) {
        self._hour = hour
        self._minute = minute
        self.onSave = onSave

        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour.wrappedValue, minute: minute.wrappedValue, second: 0, of: Date())!
        self._selectedDate = State(initialValue: date)
    }

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Reminder Time",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()

                Spacer()
            }
            .navigationTitle("Set Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let calendar = Calendar.current
                        hour = calendar.component(.hour, from: selectedDate)
                        minute = calendar.component(.minute, from: selectedDate)
                        onSave()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SettingsView()
}
