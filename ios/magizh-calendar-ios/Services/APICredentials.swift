import Foundation

/// API credentials configuration
/// In production, the API key should be bundled securely or fetched at first launch
enum APICredentials: Sendable {

    /// Get API key for current environment
    /// This retrieves from Keychain (production) or uses bundled key (development)
    static func getAPIKey() async -> String? {
        #if DEBUG
        // For development, use the bundled dev key
        return developmentKey
        #else
        // For production, retrieve from Keychain
        do {
            return try await KeychainService.shared.retrieveAPIKey()
        } catch {
            print("Failed to retrieve API key from Keychain: \(error)")
            return nil
        }
        #endif
    }

    /// Store API key (called once during app setup or from server)
    static func storeAPIKey(_ key: String) async throws {
        try await KeychainService.shared.storeAPIKey(key)
    }

    /// Check if API key is available
    static func hasAPIKey() async -> Bool {
        #if DEBUG
        return true // Always available in debug
        #else
        return await KeychainService.shared.hasAPIKey()
        #endif
    }

    /// Client type identifier sent with requests
    static let clientType = "ios"

    // MARK: - Private

    /// Development API key (bundled in debug builds only)
    /// This matches the dev key in backend's application.yml
    private static let developmentKey: String = "dev-key-for-local-testing"
}
