import SwiftUI

struct CalculatorButton: View {
    let text: String
    let color: Color
    let fontSize: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: fontSize, weight: .bold))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
    }
}
