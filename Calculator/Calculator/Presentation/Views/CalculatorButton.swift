import SwiftUI

struct CalculatorButton: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    init(text: String, color: Color = .white, action: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(color == .white ? .black : .white)
                .background(color)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
    }
}
