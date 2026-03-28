import Foundation

enum TMDBAuthenticationMode: Equatable {
    case apiKey
    case bearerToken
}

enum TMDBConfiguration {
    static let apiBaseURL = URL(string: "https://api.themoviedb.org/3")!
    static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p")!
    private static let infoDictionaryKey = "TMDBAPIKey"
    static let rawCredential = resolveCredential()

    static var authenticationMode: TMDBAuthenticationMode {
        if rawCredential.hasPrefix("eyJ") || rawCredential.hasPrefix("sk-") || rawCredential.contains(".") {
            return .bearerToken
        }

        return .apiKey
    }

    private static func resolveCredential() -> String {
        if let environmentCredential = ProcessInfo.processInfo.environment["TMDB_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !environmentCredential.isEmpty {
            return environmentCredential
        }

        if let infoDictionaryCredential = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            let trimmedCredential = infoDictionaryCredential.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedCredential.isEmpty {
                return trimmedCredential
            }
        }

        return ""
    }
}
