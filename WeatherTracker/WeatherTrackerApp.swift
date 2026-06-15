import SwiftUI
import SwiftData

@main
struct WeatherTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherView()
        }
        .modelContainer(for: SavedLocation.self)
    }
}
