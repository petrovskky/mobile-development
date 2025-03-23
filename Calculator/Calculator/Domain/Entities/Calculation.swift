import Foundation

struct Calculation {
    let expression: String
    let result: Double?
    let is_error: Bool
    
    init(expression: String, result: Double? = nil, is_error: Bool = false) {
        self.expression = expression
        self.result = result
        self.is_error = is_error
    }
}
