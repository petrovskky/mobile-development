import Foundation
import SwiftUI
import UserNotifications

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var theme: Theme = Theme(primaryColor: "#0064FF", fontSize: 14.0)
    @Published var notificationSettings = NotificationSettings()
    private let repository = FirebaseRepository()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func loadTheme() async {
        do {
            let loadedTheme = try await repository.getTheme()
            theme = loadedTheme
        } catch {
            print("Ошибка загрузки темы: \(error)")
        }
    }
    
    func saveTheme() {
        repository.saveTheme(theme: theme)
    }
    
    func saveNotificationSettings() {
        repository.saveNotificationSettings(settings: notificationSettings)
    }
    
    func requestNotificationPermission() async {
        do {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Ошибка разрешения уведомлений: \(error)")
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Тестовое уведомление"
        content.body = notificationSettings.notificationText
        content.sound = .default
        
        let now = Date()
        let calendar = Calendar.current
        let notificationTimeComponents = calendar.dateComponents([.hour, .minute],
                                                              from: notificationSettings.notificationTime)
        
        var nextNotificationDate = calendar.nextDate(after: now,
                                                   matching: notificationTimeComponents,
                                                   matchingPolicy: .nextTime) ?? now
        
        if nextNotificationDate <= now {
            nextNotificationDate = calendar.date(byAdding: .day, value: 1, to: nextNotificationDate) ?? now
        }
        
        let timeDifference = nextNotificationDate.timeIntervalSince(now)
        print(timeDifference)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeDifference, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при планировании уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление запланировано!")
            }
        }
    }
    
    func cancelNotification() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["calculator_reminder"])
    }
}
