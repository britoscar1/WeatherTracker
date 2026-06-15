import SwiftUI
import SwiftData

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedLocation.createdAt) private var locations: [SavedLocation]
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingAddSheet = false

    private var isNight: Bool {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 6 || h >= 20
    }

    private var bgColor: Color {
        isNight ? Color(red: 0.10, green: 0.11, blue: 0.18) : Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    private var fgColor: Color {
        isNight ? .white : Color(red: 0.18, green: 0.18, blue: 0.28)
    }

    private let maxLocations = 4

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()

                if locations.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(locations) { location in
                            NavigationLink {
                                LocationDetailView(location: location, viewModel: viewModel)
                            } label: {
                                LocationRowView(location: location, viewModel: viewModel)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                        }
                        .onDelete(perform: deleteLocations)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable { viewModel.fetchAll(locations: locations) }
                }
            }
            .navigationTitle("Weather Watchlist")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(isNight ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(fgColor)
                    }
                    .disabled(locations.count >= maxLocations)
                }
                if !locations.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .foregroundColor(fgColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLocationView(viewModel: viewModel) { location in
                    modelContext.insert(location)
                    viewModel.fetchWeather(for: location)
                }
            }
            .onAppear {
                viewModel.fetchAll(locations: locations)
            }
        }
    }

    private func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            viewModel.cancelFetch(for: location.id)
            modelContext.delete(location)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 64))
                .foregroundColor(fgColor.opacity(0.4))
            Text("No Locations")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(fgColor)
            Text("Tap + to add up to \(maxLocations) locations")
                .font(.subheadline)
                .foregroundColor(fgColor.opacity(0.45))
        }
    }
}
