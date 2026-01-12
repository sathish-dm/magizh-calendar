import SwiftUI
import MapKit

/// Location search view with autocomplete
struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = LocationSearchService()
    @ObservedObject private var settings = SettingsService.shared

    let mode: LocationSearchMode
    var onLocationSelected: ((Location) -> Void)?

    @State private var searchText = ""
    @State private var isLoadingDetails = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if searchText.isEmpty {
                // Popular locations when not searching
                Section("Popular Cities") {
                    ForEach(Location.popularLocations) { location in
                        Button {
                            selectLocation(location)
                        } label: {
                            locationRow(location)
                        }
                    }
                }
            } else {
                // Search results
                if searchService.suggestions.isEmpty {
                    if searchService.isSearching {
                        HStack {
                            Spacer()
                            ProgressView("Searching...")
                            Spacer()
                        }
                    } else {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("Try a different city name")
                        )
                    }
                } else {
                    Section("Search Results") {
                        ForEach(searchService.suggestions, id: \.self) { suggestion in
                            Button {
                                Task {
                                    await selectSuggestion(suggestion)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(suggestion.title)
                                        .foregroundStyle(.primary)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search any city...")
        .onChange(of: searchText) { _, newValue in
            searchService.search(query: newValue)
        }
        .navigationTitle(mode.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .overlay {
            if isLoadingDetails {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("Getting location...")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Location Row

    private func locationRow(_ location: Location) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .foregroundStyle(.primary)
                Text("\(location.city), \(location.country)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if location.id == settings.defaultLocation.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
            }
        }
    }

    // MARK: - Actions

    private func selectLocation(_ location: Location) {
        print("DEBUG: selectLocation called for \(location.name)")
        switch mode {
        case .setDefault:
            settings.defaultLocation = location
        case .addFavorite:
            settings.addFavorite(location)
        }
        onLocationSelected?(location)
        dismiss()
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) async {
        isLoadingDetails = true
        errorMessage = nil

        do {
            let location = try await searchService.getLocationDetails(from: suggestion)
            await MainActor.run {
                isLoadingDetails = false
                selectLocation(location)
            }
        } catch {
            await MainActor.run {
                isLoadingDetails = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Search Mode

enum LocationSearchMode {
    case setDefault
    case addFavorite

    var title: String {
        switch self {
        case .setDefault: return "Select Location"
        case .addFavorite: return "Add to Favorites"
        }
    }
}

#Preview {
    NavigationStack {
        LocationSearchView(mode: .setDefault)
    }
}
