import Security
import Foundation

class PassKeyManager: ObservableObject {
    @Published private(set) var isPassKeySet: Bool = false
    @Published var failedAttempts: Int = 0
    private let maxAttempts = 3
    private let keyTitle = "calculatorPassKey";
    
    init() {
        checkPassKeyStatus()
    }
    
    private func checkPassKeyStatus() {
        isPassKeySet = loadFromKeychain() != nil
    }
    
    func setPassKey(_ passKey: String) -> Result<Bool, PassKeyError> {
        guard passKey.count >= 4 else {
            return .failure(.tooShort)
        }
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTitle,
            kSecValueData: passKey.data(using: .utf8)!
        ] as CFDictionary
        
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        
        if status == noErr {
            isPassKeySet = true
            failedAttempts = 0
            return .success(true)
        }
        return .failure(.saveError)
    }
    
    func verifyPassKey(_ passKey: String) -> Bool {
        guard let storedPassKey = loadFromKeychain() else { return false }
        let isValid = passKey == storedPassKey
        
        if !isValid {
            failedAttempts += 1
        } else {
            failedAttempts = 0
        }
        
        return isValid
    }
    
    func removePassKey() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTitle
        ] as CFDictionary
        SecItemDelete(query)
        isPassKeySet = false
        failedAttempts = 0
    }
    
    private func loadFromKeychain() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTitle,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query, &item)
        
        guard status == noErr,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }
    
    var isLockedOut: Bool {
        failedAttempts >= maxAttempts
    }
}
