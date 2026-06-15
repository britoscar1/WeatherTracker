import Foundation
import SwiftData

@Model
final class SavedLocation {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var baselineTemp: Double
    var note: String?
    var createdAt: Date

    init(name: String, latitude: Double, longitude: Double, baselineTemp: Double, note: String? = nil) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.baselineTemp = baselineTemp
        self.note = note
        self.createdAt = Date()
    }
}
