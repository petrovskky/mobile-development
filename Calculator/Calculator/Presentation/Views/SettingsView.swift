//
//  SettingsView.swift
//  Calculator
//
//  Created by Viktor on 12.03.25.
//

import SwiftUI

struct SettingsView: View {
    @State private var isNotificationsEnabled = false
    
    var body: some View {
        Form {
            Section(header: Text("Уведомления")) {
                Toggle("Включить уведомления", isOn: $isNotificationsEnabled)
                    .onChange(of: isNotificationsEnabled) { newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
                
                Button("Запланировать тестовое уведомление") {
                    scheduleNotification()
                }
                .disabled(!isNotificationsEnabled)
            }
        }
        .navigationTitle("Настройки")
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено.")
            } else if let error = error {
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Тестовое уведомление"
        content.body = "Это тестовое уведомление из калькулятора!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при планировании уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление запланировано!")
            }
        }
    }
}
