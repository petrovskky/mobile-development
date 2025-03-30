import SwiftUI

struct CalculatorKeypad: View {
    let onKeyPressed: (String) -> Void
    @EnvironmentObject var settings: SettingsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let buttons = isLandscape ? buttonsHorizontal : buttonsVertical
            
            VStack(spacing: 1) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButton(
                                text: button,
                                color: buttonColor(for: button),
                                fontSize: CGFloat(settings.theme.fontSize),
                                action: { onKeyPressed(button) }
                            )
                        }
                    }
                }
            }
            .padding(8)
        }
    }
    
    var buttonsVertical: [[String]] = [
        ["C", "√", "!", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "⌫", "="]
    ]
    
    var buttonsHorizontal: [[String]] = [
        ["C", "ln", "√", "!", "÷"],
        ["sin", "7", "8", "9", "×"],
        ["cos", "4", "5", "6", "-"],
        ["tan", "1", "2", "3", "+"],
        ["ctg", "0", ".", "⌫", "="]
    ]
    
    func buttonColor(for button: String) -> Color {
        switch button {
        case "C": return .red
        case "=": return .green
        case "sin", "cos", "tan", "ctg", "ln": return .orange
        case "√", "!", "÷", "×", "-", "+": return Color(hex: settings.theme.primaryColor)
        default: return .gray
        }
    }
}
