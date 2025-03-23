import Foundation
import FirebaseFirestore

class FirebaseRepository: DataBaseRepository {
    func saveTheme(theme: Theme) {
        let db = Firestore.firestore()
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "deviceID"
        
        db.collection("users").document(deviceID).setData([
            "primaryColor": theme.primaryColor,
            "fontSize": theme.fontSize
        ]) { error in
            if let error = error {
                print("Error saving theme: \(error.localizedDescription)")
            } else {
                print("Theme saved successfully!")
            }
        }
    }

    func getTheme() async throws -> Theme {
        let db = Firestore.firestore()
        let deviceID = (await UIDevice.current.identifierForVendor?.uuidString) ?? "deviceID"
        
        let snapshot = try await db.collection("users").document(deviceID).getDocument()
        
        guard let data = snapshot.data() else {
            print("No theme data found")
            return Theme()
        }
        
        let theme = Theme(
            primaryColor: data["primaryColor"] as? String ?? "#FFFFFF",
            fontSize: data["fontSize"] as? Float ?? 14.0
        )
        
        return theme
    }
}
