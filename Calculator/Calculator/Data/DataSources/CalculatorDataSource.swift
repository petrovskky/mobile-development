import Foundation
import UIKit

protocol CalculatorDataSource {
    func evaluateExpression(_ expression: String) async throws -> Double
}

class CalculatorDataSourceImpl: CalculatorDataSource {
    func isValidPhoneNumber(phone: String) -> Bool {
        let phoneWithoutSpace = phone.replacingOccurrences(of: " ", with: "")
        let phonePattern = "^(\\+375(29|33|25|44)|80(29|33|25|44))?\\d{7}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phonePattern)
        return predicate.evaluate(with: phoneWithoutSpace)
    }
    
    func evaluateExpression(_ expression: String) async throws -> Double {
        if isValidPhoneNumber(phone: expression) {
            if let url = URL(string: "tel://\(expression)"), await UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }
        let forbiddenEndingOperators: [String] = ["√", "÷", "+", "-", "×"]
        if forbiddenEndingOperators.contains(where: { expression.hasSuffix($0) }) {
            throw NSError(domain: "CalculatorError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Wrong expression"])
        }
        var expr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "√", with: "sqrt")
            .replacingOccurrences(of: "!", with: "fact")
        
        expr = try preprocessMultiplication(expr)
        
        return try evaluateExpressionInternal(expr)
    }
    
    private func preprocessMultiplication(_ expr: String) throws -> String {
        var modifiedExpr = expr
        
        let functionRegex = try NSRegularExpression(pattern: #"\d+(\.\d+)?(sqrt|ln|sin|cos|tan|ctg)"#)
        let functionRange = NSRange(modifiedExpr.startIndex..<modifiedExpr.endIndex, in: modifiedExpr)
        let functionMatches = functionRegex.matches(in: modifiedExpr, range: functionRange)
        
        for match in functionMatches.reversed() {
            if let matchRange = Range(match.range, in: modifiedExpr) {
                let matchedString = String(modifiedExpr[matchRange])
                let numberEndIndex = matchedString.range(of: #"\d+(\.\d+)?"#, options: .regularExpression)!.upperBound
                let functionStartIndex = matchedString.index(numberEndIndex, offsetBy: 0)
                
                let numberPart = String(matchedString[..<numberEndIndex])
                let functionPart = String(matchedString[functionStartIndex...])
                
                let replacement = "\(numberPart)*\(functionPart)"
                modifiedExpr.replaceSubrange(matchRange, with: replacement)
            }
        }
        
        let factorialRegex = try NSRegularExpression(pattern: #"fact\d+(\.\d+)?"#)
        let factorialRange = NSRange(modifiedExpr.startIndex..<modifiedExpr.endIndex, in: modifiedExpr)
        let factorialMatches = factorialRegex.matches(in: modifiedExpr, range: factorialRange)
        
        for match in factorialMatches.reversed() {
            if let matchRange = Range(match.range, in: modifiedExpr) {
                let matchedString = String(modifiedExpr[matchRange])
                let numberStartIndex = matchedString.index(matchedString.startIndex, offsetBy: 4)
                
                let factorialPart = String(matchedString[..<numberStartIndex])
                let numberPart = String(matchedString[numberStartIndex...])
                
                let replacement = "\(factorialPart)*\(numberPart)"
                modifiedExpr.replaceSubrange(matchRange, with: replacement)
            }
        }
        
        return modifiedExpr
    }
    
    private func evaluateExpressionInternal(_ expression: String) throws -> Double {
        var expr = preprocessNegativeParentheses(expression)
        expr = expr.replacingOccurrences(of: " ", with: "")
        
        if expr.contains("fact") {
            let factRegex = try NSRegularExpression(pattern: #"\d+(\.\d+)?fact"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = factRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let factExpression = String(expr[matchRange])
                    let numberStr = String(factExpression.dropLast(4))
                    
                    guard let number = Int(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    if number < 0 {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Factorial is only defined for non-negative integers"])
                    }
                    
                    let factResult = try factorial(number)
                    expr = expr.replacingOccurrences(of: factExpression, with: String(factResult))
                }
            }
        }
        
        if expr.contains("sqrt") {
            let sqrtRegex = try NSRegularExpression(pattern: #"sqrt\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = sqrtRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let sqrtExpression = String(expr[matchRange])
                    let numberStr = String(sqrtExpression.dropFirst(4))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    if number < 0 {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Cannot calculate square root of negative number"])
                    }
                    
                    let sqrtResult = sqrt(number)
                    expr = expr.replacingOccurrences(of: sqrtExpression, with: String(sqrtResult))
                }
            }
        }
        
        if expr.contains("ln") {
            let lnRegex = try NSRegularExpression(pattern: #"ln\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = lnRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let lnExpression = String(expr[matchRange])
                    let numberStr = String(lnExpression.dropFirst(2))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    if number <= 0 {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Cannot calculate logarithm of non-positive number"])
                    }
                    
                    let lnResult = log(number)
                    expr = expr.replacingOccurrences(of: lnExpression, with: String(lnResult))
                }
            }
        }
        
        if expr.contains("sin") {
            let sinRegex = try NSRegularExpression(pattern: #"sin\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = sinRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let sinExpression = String(expr[matchRange])
                    let numberStr = String(sinExpression.dropFirst(3))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    let sinResult = sin(number * .pi / 180)
                    let roundSinResult = round(sinResult * 1_000_000_000_000_000) / 1_000_000_000_000_000
                    expr = expr.replacingOccurrences(of: sinExpression, with: String(roundSinResult))
                }
            }
        }
        
        if expr.contains("cos") {
            let cosRegex = try NSRegularExpression(pattern: #"cos\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = cosRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let cosExpression = String(expr[matchRange])
                    let numberStr = String(cosExpression.dropFirst(3))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    let cosResult = cos(number * .pi / 180)
                    let roundCosResult = round(cosResult * 1_000_000_000_000_000) / 1_000_000_000_000_000
                    expr = expr.replacingOccurrences(of: cosExpression, with: String(roundCosResult))
                }
            }
        }
        
        if expr.contains("tan") {
            let tanRegex = try NSRegularExpression(pattern: #"tan\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = tanRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let tanExpression = String(expr[matchRange])
                    let numberStr = String(tanExpression.dropFirst(3))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    let tanResult = tan(number * .pi / 180)
                    let roundTanResult = round(tanResult * 1_000_000_000_000_000) / 1_000_000_000_000_000
                    expr = expr.replacingOccurrences(of: tanExpression, with: String(roundTanResult))
                }
            }
        }
        
        if expr.contains("ctg") {
            let ctgRegex = try NSRegularExpression(pattern: #"ctg\d+(\.\d+)?"#)
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            let matches = ctgRegex.matches(in: expr, range: range)
            
            for match in matches.reversed() {
                if let matchRange = Range(match.range, in: expr) {
                    let ctgExpression = String(expr[matchRange])
                    let numberStr = String(ctgExpression.dropFirst(3))
                    
                    guard let number = Double(numberStr) else {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
                    }
                    
                    let tanValue = tan(number * .pi / 180)
                    if tanValue == 0 {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Cannot calculate cotangent of 90 degrees"])
                    }
                    
                    let ctgResult = 1 / tanValue
                    let roundCtgResult = round(ctgResult * 1_000_000_000_000_000) / 1_000_000_000_000_000
                    expr = expr.replacingOccurrences(of: ctgExpression, with: String(roundCtgResult))
                }
            }
        }
        
        while expr.contains("(") {
            guard let openIndex = expr.lastIndex(of: "(") else {
                throw NSError(domain: "CalculatorError", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid expression"])
            }
            
            var closeIndex: String.Index?
            var openCount = 1
            
            var currentIndex = expr.index(after: openIndex)
            while currentIndex < expr.endIndex {
                if expr[currentIndex] == "(" {
                    openCount += 1
                }
                if expr[currentIndex] == ")" {
                    openCount -= 1
                    if openCount == 0 {
                        closeIndex = currentIndex
                        break
                    }
                }
                currentIndex = expr.index(after: currentIndex)
            }
            
            guard let closeIdx = closeIndex else {
                throw NSError(domain: "CalculatorError", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Mismatched parentheses"])
            }
            
            let subExpr = String(expr[expr.index(after: openIndex)..<closeIdx])
            let result = try evaluateExpressionInternal(subExpr)
            
            var resultStr = String(result)
            if result < 0 && openIndex > expr.startIndex {
                let prevCharIndex = expr.index(before: openIndex)
                if ["*", "/"].contains(expr[prevCharIndex]) {
                    resultStr = "(" + resultStr + ")"
                }
            }
            
            let prefix = expr[..<openIndex]
            let suffix = expr[expr.index(after: closeIdx)...]
            expr = String(prefix) + resultStr + String(suffix)
        }
        
        let addSubtractTokens = splitByOperators(expression: expr, operators: ["+", "-"])
        if addSubtractTokens.count > 1 {
            var result = try evaluateExpressionInternal(addSubtractTokens[0])
            
            var i = 1
            while i < addSubtractTokens.count {
                let op = addSubtractTokens[i]
                let operand = try evaluateExpressionInternal(addSubtractTokens[i+1])
                
                if op == "+" {
                    result += operand
                } else {
                    result -= operand
                }
                
                i += 2
            }
            
            return result
        }
        
        let multiplyDivideTokens = splitByOperators(expression: expr, operators: ["*", "/"])
        if multiplyDivideTokens.count > 1 {
            var result = try evaluateExpressionInternal(multiplyDivideTokens[0])
            
            var i = 1
            while i < multiplyDivideTokens.count {
                let op = multiplyDivideTokens[i]
                let operand = try evaluateExpressionInternal(multiplyDivideTokens[i+1])
                
                if op == "*" {
                    result *= operand
                } else {
                    if operand == 0 {
                        throw NSError(domain: "CalculatorError", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Division by zero"])
                    }
                    result /= operand
                }
                
                i += 2
            }
            
            return result
        }
        
        guard let number = Double(expr) else {
            throw NSError(domain: "CalculatorError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid number format"])
        }
        
        return number
    }
    
    private func preprocessNegativeParentheses(_ expression: String) -> String {
        var expr = expression
        
        if let regex = try? NSRegularExpression(pattern: #"\(\s*-"#) {
            let range = NSRange(expr.startIndex..<expr.endIndex, in: expr)
            expr = regex.stringByReplacingMatches(in: expr, range: range, withTemplate: "(0-")
        }
        
        expr = expr.replacingOccurrences(of: "--", with: "+")
        
        return expr
    }
    
    private func splitByOperators(expression: String, operators: [String]) -> [String] {
        var result: [String] = []
        var currentToken = ""
        
        for char in expression {
            if operators.contains(String(char)) && !currentToken.isEmpty {
                result.append(currentToken)
                result.append(String(char))
                currentToken = ""
            } else {
                currentToken.append(char)
            }
        }
        
        if !currentToken.isEmpty {
            result.append(currentToken)
        }
        
        return result
    }
    
    private func factorial(_ n: Int) throws -> Double {
        if n > 18 {
            throw NSError(domain: "CalculatorError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Factorial parameter is out of range"])
        }
        var result: Double = 1.0
        for i in 2...n {
            result *= Double(i)
        }
        return result
    }
}
