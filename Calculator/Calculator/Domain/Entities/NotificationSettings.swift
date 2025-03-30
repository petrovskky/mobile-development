import Foundation

struct NotificationSettings: Codable {
    var isEnabled: Bool = false
    var notificationText: String = "Не забудь посчитать в калькуляторе сегодня!"
    var notificationTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
}
