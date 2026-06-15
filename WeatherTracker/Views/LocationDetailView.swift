import SwiftUI

struct LocationDetailView: View {
    let location: SavedLocation
    @ObservedObject var viewModel: WeatherViewModel

    private var hour: Int { Calendar.current.component(.hour, from: Date()) }
    private var isNight: Bool { hour < 6 || hour >= 20 }

    private var greeting: String {
        switch hour {
        case 6..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<20: return "GOOD EVENING"
        default:      return "GOOD NIGHT"
        }
    }

    private var dayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE  h:mm a"
        return f.string(from: Date()).uppercased()
    }

    private var bgColor: Color {
        isNight
            ? Color(red: 0.13, green: 0.14, blue: 0.22)
            : Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    private var fgColor: Color {
        isNight ? .white : Color(red: 0.18, green: 0.18, blue: 0.28)
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            switch viewModel.weatherStates[location.id] ?? .loading {
            case .loading:
                ProgressView().tint(fgColor)

            case .failed(let msg):
                VStack(spacing: 16) {
                    Text(msg)
                        .foregroundColor(fgColor.opacity(0.7))
                    Button("Retry") { viewModel.fetchWeather(for: location) }
                        .foregroundColor(fgColor)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(fgColor.opacity(0.4)))
                }

            case .loaded(let weather):
                mainContent(weather: weather)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(isNight ? .dark : .light, for: .navigationBar)
        .onAppear { viewModel.fetchWeather(for: location) }
    }

    private func mainContent(weather: CurrentWeather) -> some View {
        let delta   = viewModel.delta(current: weather.temperature, baseline: location.baselineTemp)
        let percent = viewModel.percentChange(current: weather.temperature, baseline: location.baselineTemp)
        let isUp    = delta >= 0

        return VStack(spacing: 0) {

            // City + date
            VStack(spacing: 6) {
                Text(location.name)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(fgColor)
                Text(dayString)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(fgColor.opacity(0.55))
            }
            .padding(.top, 12)

            Spacer()

            // Weather icon
            Image(systemName: weatherIcon(for: weather.weatherCode))
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 110))
                .shadow(color: .black.opacity(0.12), radius: 12)

            Spacer()

            // Temperature
            Text(String(format: "%.0f°c", weather.temperature))
                .font(.system(size: 60, weight: .thin))
                .foregroundColor(fgColor)

            // Greeting + delta
            VStack(spacing: 4) {
                Text(greeting)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(2.5)
                    .foregroundColor(fgColor.opacity(0.45))

                HStack(spacing: 4) {
                    Image(systemName: isUp ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    Text(String(format: "%+.1f°", delta))
                        .font(.system(size: 12, weight: .medium))
                    if let pct = percent {
                        Text(String(format: "(%+.1f%%)", pct))
                            .font(.system(size: 11))
                    }
                }
                .foregroundColor(isUp ? .red.opacity(0.8) : Color(red: 0.3, green: 0.6, blue: 1.0))
            }
            .padding(.top, 4)

            Spacer()

            // Divider
            Rectangle()
                .fill(fgColor.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 28)

            // Bottom stats row
            HStack(spacing: 0) {
                WeatherStatItem(
                    icon: isNight ? "moon.horizon.fill" : "sun.horizon.fill",
                    label: isNight ? "SUNSET" : "SUNRISE",
                    value: shortTime(from: weather.time),
                    fgColor: fgColor
                )
                WeatherStatItem(
                    icon: "wind",
                    label: "WIND",
                    value: String(format: "%.0fm/s", weather.windSpeed / 3.6),
                    fgColor: fgColor
                )
                WeatherStatItem(
                    icon: "thermometer.medium",
                    label: "TEMPERATURE",
                    value: String(format: "%.0f°", weather.temperature),
                    fgColor: fgColor
                )
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0:          return isNight ? "moon.stars.fill"      : "sun.max.fill"
        case 1, 2, 3:   return isNight ? "cloud.moon.fill"      : "cloud.sun.fill"
        case 45, 48:     return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default:         return "cloud.fill"
        }
    }

    // Parses "2024-01-01T14:30" → "14:30"
    private func shortTime(from iso: String) -> String {
        let parts = iso.split(separator: "T")
        guard parts.count == 2 else { return "--:--" }
        let t = String(parts[1]).split(separator: ":")
        guard t.count >= 2 else { return String(parts[1]) }
        return "\(t[0]):\(t[1])"
    }
}

private struct WeatherStatItem: View {
    let icon: String
    let label: String
    let value: String
    let fgColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(fgColor.opacity(0.75))
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(fgColor)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .tracking(1.2)
                .foregroundColor(fgColor.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}
