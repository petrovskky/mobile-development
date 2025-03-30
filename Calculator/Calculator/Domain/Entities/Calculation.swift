import Foundation

struct Calculation {
    let id: String
    let expression: String
    let result: Double?
    let is_error: Bool
    
    init(expression: String, result: Double? = nil, is_error: Bool = false) {
        self.id = UUID().uuidString
        self.expression = expression
        self.result = result
        self.is_error = is_error
    }
}
