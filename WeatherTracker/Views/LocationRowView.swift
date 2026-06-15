import SwiftUI

struct LocationRowView: View {
    let location: SavedLocation
    @ObservedObject var viewModel: WeatherViewModel

    private var isNight: Bool {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 6 || h >= 20
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)

            HStack(spacing: 12) {
                // Left: name + condition
                VStack(alignment: .leading, spacing: 6) {
                    Text(location.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(cardForeground)

                    if case .loaded(let weather) = viewModel.weatherStates[location.id] {
                        Text(CurrentWeather.label(for: weather.weatherCode))
                            .font(.system(size: 12))
                            .foregroundColor(cardForeground.opacity(0.5))
                    }
                }

                Spacer()

                // Center: weather icon
                if case .loaded(let weather) = viewModel.weatherStates[location.id] {
                    Image(systemName: weatherIcon(for: weather.weatherCode))
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 36))
                }

                Spacer()

                // Right: temp + delta
                switch viewModel.weatherStates[location.id] ?? .loading {
                case .loading:
                    ProgressView().tint(cardForeground)
                case .loaded(let weather):
                    loadedRight(weather: weather)
                case .failed:
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func loadedRight(weather: CurrentWeather) -> some View {
        let delta = viewModel.delta(current: weather.temperature, baseline: location.baselineTemp)
        let isUp  = delta >= 0

        return VStack(alignment: .trailing, spacing: 4) {
            Text(String(format: "%.0f°c", weather.temperature))
                .font(.system(size: 22, weight: .light))
                .foregroundColor(cardForeground)

            HStack(spacing: 3) {
                Image(systemName: isUp ? "arrow.up" : "arrow.down")
                    .font(.system(size: 9))
                Text(String(format: "%+.1f°", delta))
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isUp ? .red.opacity(0.8) : Color(red: 0.3, green: 0.6, blue: 1.0))
        }
    }

    private var cardBackground: Color {
        isNight ? Color(red: 0.17, green: 0.18, blue: 0.28) : Color(.systemBackground)
    }

    private var cardForeground: Color {
        isNight ? .white : Color(red: 0.18, green: 0.18, blue: 0.28)
    }

    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0:          return isNight ? "moon.stars.fill"  : "sun.max.fill"
        case 1, 2, 3:   return isNight ? "cloud.moon.fill"  : "cloud.sun.fill"
        case 45, 48:     return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default:         return "cloud.fill"
        }
    }
}
