import Foundation

struct Theme: Codable { // to json, from json convertation
    var primaryColor: String
    var fontSize: Float
    
    init() {
        self.primaryColor = "#FFFFFF"
        self.fontSize = 14.0
    }
    
    init(primaryColor: String, fontSize: Float) {
        self.primaryColor = primaryColor
        self.fontSize = fontSize
    }
}
