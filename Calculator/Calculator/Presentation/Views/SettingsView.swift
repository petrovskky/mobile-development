import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @EnvironmentObject var passKeyManager: PassKeyManager
    @State private var showNotificationAlert = false
    @State private var alertMessage = ""
    @State private var showPassKeySetup = false
    @State private var newPassKey = ""
    @State private var confirmPassKey = ""
    @State private var errorMessage = ""
    
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
            
            Section(header: Text("Pass Key")) {
                if passKeyManager.isPassKeySet {
                    Button("Изменить Pass Key") {
                        showPassKeySetup = true
                    }
                    Button("Удалить Pass Key") {
                        passKeyManager.removePassKey()
                    }
                    .foregroundColor(.red)
                } else {
                    Button("Установить Pass Key") {
                        showPassKeySetup = true
                    }
                }
            }
        }
        .navigationTitle("Настройки")
        .alert("Уведомления", isPresented: $showNotificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showPassKeySetup) {
            VStack(spacing: 20) {
                Text(passKeyManager.isPassKeySet ? "Изменить Pass Key" : "Установить Pass Key")
                    .font(.title2)
                
                SecureField("Новый Pass Key", text: $newPassKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Подтвердите Pass Key", text: $confirmPassKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                    .foregroundColor(.red)
                }
                
                Button("Сохранить") {
                    if newPassKey != confirmPassKey {
                        errorMessage = "Pass Key не совпадают"
                    } else {
                        switch passKeyManager.setPassKey(newPassKey) {
                        case .success:
                            showPassKeySetup = false
                            newPassKey = ""
                            confirmPassKey = ""
                            errorMessage = ""
                        case .failure(.tooShort):
                            errorMessage = "Минимум 4 символа"
                        case .failure(.saveError):
                            errorMessage = "Ошибка сохранения"
                        }
                    }
                }
                
                Button("Отмена") {
                    showPassKeySetup = false
                    newPassKey = ""
                    confirmPassKey = ""
                    errorMessage = ""
                }
            }
            .padding()
        }
        .task {
            await settings.loadTheme()
        }
    }
}
