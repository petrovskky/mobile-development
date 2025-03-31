import SwiftUI

struct PassKeyView: View {
    @EnvironmentObject var passKeyManager: PassKeyManager
    @Binding var isPresented: Bool
    let onSuccess: () -> Void
    
    @State private var inputPassKey = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Введите Pass Key")
                .font(.title2)
            
            SecureField("Pass Key", text: $inputPassKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 200)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if passKeyManager.isLockedOut {
                Text("Слишком много попыток. Используйте восстановление.")
                    .foregroundColor(.red)
            }
            
            Button("Подтвердить") {
                if passKeyManager.verifyPassKey(inputPassKey) {
                    isPresented = false
                    onSuccess()
                } else {
                    errorMessage = passKeyManager.isLockedOut ?
                        "Доступ заблокирован" : "Неверный Pass Key"
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(passKeyManager.isLockedOut)
            
            Button("Забыли Pass Key?") {
                errorMessage = "Свяжитесь с поддержкой для восстановления"
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}
