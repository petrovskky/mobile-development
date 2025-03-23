import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let displayHeight = geometry.size.height * 0.3
                let keypadHeight = geometry.size.height * 0.7
                
                VStack(spacing: 0) {
                    CalculatorDisplay(calculation: viewModel.calculation)
                        .frame(height: displayHeight)
                    
                    CalculatorKeypad(onKeyPressed: { key in
                        viewModel.processKey(key)
                    })
                    .frame(height: keypadHeight)
                }
            }
            .navigationTitle("Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                                    NavigationLink(destination: SettingsView()) {
                                        Image(systemName: "gear")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleSpeechRecognition()
                    }) {
                        Image(systemName: viewModel.isListening ? "mic.fill" : "mic")
                            .font(.title3)
                            .foregroundColor(viewModel.isListening ? .red : .blue)
                    }
                }
            }
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
