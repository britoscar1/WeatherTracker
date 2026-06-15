import SwiftUI

struct AddLocationView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let onAdd: (SavedLocation) -> Void

    @State private var baselineText: String = ""
    @State private var note: String = ""
    @State private var showBaselineError: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var cityFound: Bool {
        if case .found = viewModel.searchState { return true }
        return false
    }

    private var baselineIsValid: Bool {
        Double(baselineText) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Search City") {
                    HStack {
                        TextField("City name...", text: $viewModel.searchText)
                            .onSubmit { viewModel.searchCity() }
                        Button("Search") { viewModel.searchCity() }
                            .buttonStyle(.borderless)
                    }
                    searchResultRow
                }

                if cityFound {
                    Section {
                        TextField("e.g. 20.0", text: $baselineText)
                            .keyboardType(.decimalPad)
                            .onChange(of: baselineText) { showBaselineError = false }
                    } header: {
                        Text("Baseline Temperature (°C)")
                    } footer: {
                        if showBaselineError {
                            Text("Enter a number to enable Add (e.g. 20.0)")
                                .foregroundColor(.red)
                        } else {
                            Text("Reference temperature used to calculate Δ and % change.")
                                .foregroundColor(.secondary)
                        }
                    }

                    Section("Note (Optional)") {
                        TextField("Add a note...", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetSearch()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { handleAdd() }
                }
            }
        }
    }

    @ViewBuilder
    private var searchResultRow: some View {
        switch viewModel.searchState {
        case .idle:
            EmptyView()
        case .searching:
            HStack {
                ProgressView()
                Text("Searching...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .found(let result):
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .bold()
                    Text(String(format: "%.4f, %.4f", result.latitude, result.longitude))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        case .error(let msg):
            Text(msg)
                .foregroundColor(.red)
                .font(.subheadline)
        }
    }

    private func handleAdd() {
        guard cityFound else { return }
        guard baselineIsValid else {
            showBaselineError = true
            return
        }
        addLocation()
    }

    private func addLocation() {
        guard case .found(let result) = viewModel.searchState,
              let baseline = Double(baselineText) else { return }

        let location = SavedLocation(
            name: result.name,
            latitude: result.latitude,
            longitude: result.longitude,
            baselineTemp: baseline,
            note: note.isEmpty ? nil : note
        )
        viewModel.resetSearch()
        onAdd(location)
        dismiss()
    }
}
