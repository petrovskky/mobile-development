import Foundation

class CalculateExpression {
    private let repository: CalculatorRepository
    
    init(repository: CalculatorRepository) {
        self.repository = repository
    }
    
    func execute(expression: String) async throws -> Calculation {
        return try await repository.calculate(expression: expression)
    }
}
