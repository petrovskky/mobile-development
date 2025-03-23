import SwiftUI

struct CalculatorKeypad: View {
    let onKeyPressed: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            let buttonsVertical: [[String]] = [
                ["C", "√", "!", "÷"],
                ["7", "8", "9", "×"],
                ["4", "5", "6", "-"],
                ["1", "2", "3", "+"],
                ["0", ".", "⌫", "="]
            ]
            
            let buttonsHorizontal: [[String]] = [
                ["C", "ln", "√", "!", "÷"],
                ["sin", "7", "8", "9", "×"],
                ["cos", "4", "5", "6", "-"],
                ["tan", "1", "2", "3", "+"],
                ["ctg", "0", ".", "⌫", "="]
            ]
            
            let buttons = isLandscape ? buttonsHorizontal : buttonsVertical
            
            VStack(spacing: 1) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButton(
                                text: button,
                                color: buttonColor(for: button),
                                action: { onKeyPressed(button) }
                            )
                        }
                    }
                }
            }
            .padding(8)
        }
    }
    
    private func buttonColor(for button: String) -> Color {
        switch button {
        case "C":
            return .red
        case "√", "!", "÷", "×", "-", "+":
            return .blue
        case "=":
            return .green
        case "sin", "cos", "tan", "ctg", "ln":
            return .orange
        default:
            return .gray
        }
    }
}
