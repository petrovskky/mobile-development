import Foundation

protocol CalculatorRepository {
    func calculate(expression: String) async throws -> Calculation
}
