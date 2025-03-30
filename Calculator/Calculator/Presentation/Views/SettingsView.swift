import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @State private var showNotificationAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Тема")) {
                ColorPicker("Основной цвет", selection: Binding(
                    get: { Color(hex: settings.theme.primaryColor) },
                    set: { newColor in
                        settings.theme.primaryColor = newColor.toHex()
                        settings.saveTheme()
                    }
                ))
                
                HStack {
                    Text("Размер шрифта: \(Int(settings.theme.fontSize))")
                    Slider(value: Binding(
                        get: { settings.theme.fontSize },
                        set: { newValue in
                            settings.theme.fontSize = newValue
                            settings.saveTheme()
                        }
                    ), in: 10...30, step: 1)
                }
            }
            
            Section(header: Text("Уведомления")) {
                Toggle("Разрешить уведомления", isOn: Binding(
                    get: { settings.notificationSettings.isEnabled },
                    set: { newValue in
                        settings.notificationSettings.isEnabled = newValue
                        settings.saveNotificationSettings()
                        Task {
                            if newValue {
                                await settings.requestNotificationPermission()
                            } else {
                                await settings.cancelNotification()
                            }
                        }
                    }
                ))
                
                if settings.notificationSettings.isEnabled {
                    TextField("Текст уведомления", text: Binding(
                        get: { settings.notificationSettings.notificationText },
                        set: { newValue in
                            settings.notificationSettings.notificationText = newValue
                            settings.saveNotificationSettings()
                        }
                    ))
                    
                    DatePicker("Время", selection: Binding(
                        get: { settings.notificationSettings.notificationTime },
                        set: { newValue in
                            settings.notificationSettings.notificationTime = newValue
                            settings.saveNotificationSettings()
                            Task {
                                settings.scheduleNotification()
                            }
                        }
                    ), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("Настройки")
        .alert("Уведомления", isPresented: $showNotificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await settings.loadTheme()
        }
    }
}
