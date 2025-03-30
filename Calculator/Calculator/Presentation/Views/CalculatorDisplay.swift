import SwiftUI

struct CalculatorDisplay: View {
    let calculation: Calculation
    @EnvironmentObject var settings: SettingsViewModel
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .trailing) {
                    Text(calculation.expression)
                        .font(.system(size: CGFloat(settings.theme.fontSize), weight: .regular))
                        .multilineTextAlignment(.trailing)
                        .id("expression")
                    
                    if calculation.is_error {
                        Text("error")
                            .font(.system(size: CGFloat(settings.theme.fontSize), weight: .bold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.trailing)
                    }
                    else if let result = calculation.result {
                        let formattedResult = formatResult(result)
                        Text(formattedResult)
                            .font(.system(size: CGFloat(settings.theme.fontSize) * 1.2, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(24)
            }
//            .onChange(of: calculation.expression) { _ in
//                withAnimation {
//                    proxy.scrollTo("expression", anchor: .bottom)
//                }
//            }
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }
    
    private func formatResult(_ result: Double) -> String {
        if result == floor(result) {
            return String(format: "%.0f", result)
        } else {
            return String(result)
        }
    }
}
