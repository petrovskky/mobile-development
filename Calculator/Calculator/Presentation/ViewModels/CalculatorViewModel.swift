import Foundation
import SwiftUI
import Speech

@MainActor
class CalculatorViewModel: ObservableObject {
    @Published var calculation: Calculation
    private let calculateExpression: CalculateExpression
    @Published var isListening = false
    private let firebaseRepository = FirebaseRepository()
    @Published var calculations: [Calculation]
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        self.calculation = Calculation(expression: "0")
        self.calculations = []
        let dataSource = CalculatorDataSourceImpl()
        let repository = CalculatorRepositoryImpl(dataSource: dataSource)
        self.calculateExpression = CalculateExpression(repository: repository)
    }
    
    func processKey(_ key: String) {
        switch key {
        case "C":
            clear()
        case "=":
            calculate()
        case "⌫":
            backspace()
        default:
            addToExpression(key)
        }
    }
    
    private func clear() {
        calculation = Calculation(expression: "0")
    }
    
    private func backspace() {
        if calculation.expression.count > 1 {
            calculation = Calculation(
                expression: String(calculation.expression.dropLast()),
                result: calculation.result
            )
        } else {
            calculation = Calculation(expression: "0", result: calculation.result)
        }
    }
    
    private func addToExpression(_ key: String) {
        if calculation.expression == "0" {
            calculation = Calculation(expression: key, result: calculation.result)
        } else {
            calculation = Calculation(
                expression: calculation.expression + key,
                result: calculation.result
            )
        }
    }
    
    private func calculate() {
        Task {
            do {
                let result = try await calculateExpression.execute(expression: calculation.expression)
                calculation = result
                await saveCalculation(calculation)
            } catch {
                calculation = Calculation(expression: calculation.expression, is_error: true)
            }
        }
    }
    
    private func saveCalculation(_ calc: Calculation) async {
        do {
            firebaseRepository.saveCalculation(calc)
            calculations = try await firebaseRepository.getCalculationHistory();
        } catch {
            print("Ошибка при загрузке истории")
        }
        
    }
    
    func toggleSpeechRecognition() {
        isListening ? stopSpeechRecognition() : startSpeechRecognition()
    }
    
    private func startSpeechRecognition() {
        guard !isListening else { return }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.startRecording()
                } else {
                    print("Разрешение на использование микрофона не предоставлено")
                }
            }
        }
    }
    
    private func stopSpeechRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isListening = false
    }
    
    private func startRecording() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.handleRecognizedText(recognizedText)
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopSpeechRecognition()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("Ошибка запуска аудио движка: \(error)")
        }
    }
    
    private func handleRecognizedText(_ text: String) {
        var processedText = text.replacingOccurrences(of: "целых", with: ".")
                               .replacingOccurrences(of: "точка", with: ".")
                               .replacingOccurrences(of: "запятая", with: ".")
                               .replacingOccurrences(of: "плюс", with: "+")
                               .replacingOccurrences(of: "минус", with: "-")
                               .replacingOccurrences(of: "умнож", with: "×")
                               .replacingOccurrences(of: "делить", with: "÷")
                               .replacingOccurrences(of: "корень", with: "√")
                               .replacingOccurrences(of: "факториал", with: "!")
                               .replacingOccurrences(of: "синус", with: "sin")
                               .replacingOccurrences(of: "косинус", with: "cos")
                               .replacingOccurrences(of: "тангенс", with: "tan")
                               .replacingOccurrences(of: "катангенс", with: "ctg")
                               .replacingOccurrences(of: "логарифм", with: "ln")
                               .replacingOccurrences(of: "ноль", with: "0")
                               .replacingOccurrences(of: "один", with: "1")
                               .replacingOccurrences(of: "два", with: "2")
                               .replacingOccurrences(of: "три", with: "3")
                               .replacingOccurrences(of: "четыре", with: "4")
                               .replacingOccurrences(of: "пять", with: "5")
                               .replacingOccurrences(of: "шесть", with: "6")
                               .replacingOccurrences(of: "семь", with: "7")
                               .replacingOccurrences(of: "восемь", with: "8")
                               .replacingOccurrences(of: "девять", with: "9")
                               
        
        let pattern = "[^0-9+\\-+×÷√!.sincotagl]"
        
        processedText = processedText.replacingOccurrences(
            of: pattern,
            with: "",
            options: [.regularExpression]
        )
        
        calculation = Calculation(expression: processedText, result: calculation.result)
        
        if text.contains("=") || text.contains("равно") {
            calculate();
        }
    }
}
