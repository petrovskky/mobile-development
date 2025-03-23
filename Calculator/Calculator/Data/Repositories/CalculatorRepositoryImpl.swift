import Foundation

class CalculatorRepositoryImpl: CalculatorRepository {
    private let dataSource: CalculatorDataSource
    
    init(dataSource: CalculatorDataSource) {
        self.dataSource = dataSource
    }
    
    func calculate(expression: String) async throws -> Calculation {
        let result = try await dataSource.evaluateExpression(expression)
        return Calculation(expression: expression, result: result)
    }
}
