import SwiftUI

struct PassKeySetupView: View {
    @EnvironmentObject var passKeyManager: PassKeyManager
    @Binding var isSetupComplete: Bool
    @State private var passKey = ""
    @State private var confirmPassKey = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Установите Pass Key")
                .font(.title)
            
            SecureField("Pass Key (мин. 4 символа)", text: $passKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Подтвердите Pass Key", text: $confirmPassKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Сохранить") {
                if passKey != confirmPassKey {
                    errorMessage = "Pass Key не совпадают"
                } else {
                    switch passKeyManager.setPassKey(passKey) {
                    case .success:
                        isSetupComplete = true
                    case .failure(.tooShort):
                        errorMessage = "Pass Key должен быть минимум 4 символов"
                    case .failure(.saveError):
                        errorMessage = "Ошибка сохранения"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(passKey.isEmpty || confirmPassKey.isEmpty)
        }
        .padding()
    }
}
