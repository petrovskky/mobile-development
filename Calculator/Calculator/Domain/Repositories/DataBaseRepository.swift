import Foundation

protocol DataBaseRepository {
    func saveTheme(theme: Theme)
    
    func getTheme() async throws -> Theme
    
    func saveCalculation(_ calculation: Calculation)
}
