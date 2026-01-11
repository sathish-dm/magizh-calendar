import Foundation
import MapKit
import CoreLocation
import Combine

/// Service for searching locations using Apple's MapKit
/// Uses MKLocalSearchCompleter for autocomplete and CLGeocoder for full details
@MainActor
final class LocationSearchService: NSObject, ObservableObject {

    // MARK: - Published Properties

    /// Search suggestions from MKLocalSearchCompleter
    @Published private(set) var suggestions: [MKLocalSearchCompletion] = []

    /// Whether a search is in progress
    @Published private(set) var isSearching = false

    /// Error message if search fails
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private let searchCompleter = MKLocalSearchCompleter()
    private let geocoder = CLGeocoder()

    // MARK: - Initialization

    override init() {
        super.init()
        setupSearchCompleter()
    }

    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }

    // MARK: - Public Methods

    /// Update search query (called as user types)
    func search(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            suggestions = []
            isSearching = false
            return
        }

        searchCompleter.queryFragment = query
        isSearching = true
        errorMessage = nil
    }

    /// Clear search results
    func clearSearch() {
        suggestions = []
        searchCompleter.queryFragment = ""
        errorMessage = nil
        isSearching = false
    }

    /// Get full location details from a search completion
    /// Returns a Location model with coordinates and timezone
    func getLocationDetails(from completion: MKLocalSearchCompletion) async throws -> Location {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)

        let response = try await search.start()

        guard let mapItem = response.mapItems.first else {
            throw LocationSearchError.noResults
        }

        // Get timezone using reverse geocoding
        let coordinate = mapItem.placemark.coordinate
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)

        guard let placemark = placemarks.first else {
            throw LocationSearchError.geocodingFailed
        }

        // Build Location model
        let city = placemark.locality ?? mapItem.name ?? completion.title
        let state = placemark.administrativeArea
        let country = placemark.country ?? "Unknown"

        // Get timezone - critical for panchangam calculations
        let timezone: String
        if let tz = placemark.timeZone {
            timezone = tz.identifier
        } else {
            // Fallback: use device timezone (rare case)
            timezone = TimeZone.current.identifier
        }

        return Location(
            city: city,
            state: state,
            country: country,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            timezone: timezone
        )
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchService: MKLocalSearchCompleterDelegate {

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            // Filter to prioritize city/region results (those with subtitle)
            self.suggestions = completer.results.filter { result in
                !result.subtitle.isEmpty
            }
            self.isSearching = false
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.isSearching = false
            // Don't show error for common "no results" case
            if (error as NSError).code != MKError.placemarkNotFound.rawValue {
                self.errorMessage = "Search failed. Please try again."
            }
        }
    }
}

// MARK: - Errors

enum LocationSearchError: LocalizedError {
    case noResults
    case geocodingFailed
    case invalidTimezone

    var errorDescription: String? {
        switch self {
        case .noResults:
            return "No location found. Please try a different search."
        case .geocodingFailed:
            return "Unable to get location details. Please try again."
        case .invalidTimezone:
            return "Could not determine timezone for this location."
        }
    }
}
