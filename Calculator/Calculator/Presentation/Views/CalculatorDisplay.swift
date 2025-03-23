import SwiftUI

struct CalculatorDisplay: View {
    let calculation: Calculation
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .trailing) {
                    Text(calculation.expression)
                        .font(.title2)
                        .multilineTextAlignment(.trailing)
                        .id("expression")
                    
                    if calculation.is_error {
                        Text("error")
                            .font(.title.weight(.bold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.trailing)
                    }
                    else if let result = calculation.result {
                        let formattedResult = formatResult(result)
                        Text(formattedResult)
                            .font(.title.weight(.bold))
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
        .background(Color(.systemGray6))
    }
    
    private func formatResult(_ result: Double) -> String {
        if result == floor(result) {
            return String(format: "%.0f", result)
        } else {
            return String(result)
        }
    }
}
