import Foundation
import FirebaseFirestore
import UIKit

class FirebaseRepository: DataBaseRepository {
    let db = Firestore.firestore()
    var deviceID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "deviceID"
    }
    
    func saveTheme(theme: Theme) {
        db.collection("users").document(deviceID).setData([
            "primaryColor": theme.primaryColor,
            "fontSize": theme.fontSize
        ], merge: true) { error in
            if let error = error {
                print("Error saving theme: \(error.localizedDescription)")
            } else {
                print("Theme saved successfully!")
            }
        }
    }

    func getTheme() async throws -> Theme {
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
    
    func saveCalculation(_ calculation: Calculation) {
        let data: [String: Any] = [
            "expression": calculation.expression,
            "result": calculation.result ?? 0,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(deviceID).collection("calculations").addDocument(data: data) { error in
            if let error = error {
                print("Error saving calculation: \(error.localizedDescription)")
            } else {
                print("Calculation saved successfully")
            }
        }
    }
    
    func getCalculationHistory() async throws -> [Calculation] {
        let snapshot = try await db.collection("users")
            .document(deviceID)
            .collection("calculations")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            guard let expression = doc["expression"] as? String,
                  let result = doc["result"] as? Double else { return nil }
            return Calculation(expression: expression, result: result)
        }
    }
    
    func saveNotificationSettings(settings: NotificationSettings) {
        do {
            try db.collection("users")
                .document(deviceID)
                .setData(from: settings, merge: true)
        } catch {
            print("Error saving notification settings: \(error)")
        }
    }

    func getNotificationSettings() async throws -> NotificationSettings {
        let document = try await db.collection("users")
            .document(deviceID)
            .getDocument()
        
        return try document.data(as: NotificationSettings.self)
    }
}
