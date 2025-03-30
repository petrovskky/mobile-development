import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @EnvironmentObject var settings: SettingsViewModel
    @State private var showingHistory = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                CalculatorDisplay(calculation: viewModel.calculation)
                    .frame(height: geometry.size.height * 0.3)
                
                CalculatorKeypad(onKeyPressed: { key in
                    viewModel.processKey(key)
                })
                .frame(height: geometry.size.height * 0.7)
            }
        }
        .navigationTitle("Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.system(size: CGFloat(settings.theme.fontSize)))
                            .foregroundColor(Color(hex: settings.theme.primaryColor))
                    }
                    
                    Button(action: {
                        showingHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: CGFloat(settings.theme.fontSize)))
                            .foregroundColor(Color(hex: settings.theme.primaryColor))
                    }
                    .sheet(isPresented: $showingHistory) {
                        CalculationHistoryView().environmentObject(settings)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleSpeechRecognition()
                }) {
                    Image(systemName: viewModel.isListening ? "mic.fill" : "mic")
                        .font(.system(size: CGFloat(settings.theme.fontSize)))
                        .foregroundColor(viewModel.isListening ? .red : Color(hex: settings.theme.primaryColor))
                }
            }
        }
        .onAppear {
            Task {
                await settings.loadTheme()
            }
        }
    }
}

struct CalculationHistoryView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @State private var history: [Calculation] = []
    private let repository = FirebaseRepository()
    
    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    Text("История пуста")
                        .foregroundColor(.gray)
                } else {
                    List(history, id: \.id) { calculation in
                        VStack(alignment: .leading) {
                            Text(calculation.expression)
                                .font(.system(size: CGFloat(settings.theme.fontSize)))
                            if let result = calculation.result {
                                Text("= \(result)")
                                    .font(.system(size: CGFloat(settings.theme.fontSize) * 0.9))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("История")
            .onAppear {
                loadHistory()
            }
        }
    }
    
    private func loadHistory() {
        Task {
            do {
                let fetchedHistory = try await repository.getCalculationHistory()
                await MainActor.run {
                    history = fetchedHistory
                }
            } catch {
                print("Error loading history: \(error)")
            }
        }
    }
}
