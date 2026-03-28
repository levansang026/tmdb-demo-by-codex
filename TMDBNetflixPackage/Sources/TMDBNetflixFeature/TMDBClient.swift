import Foundation
import SwiftUI

enum TMDBError: LocalizedError, Sendable {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The response from TMDB was invalid."
        case let .requestFailed(statusCode, message):
            return "TMDB request failed (\(statusCode)): \(message)"
        }
    }
}

struct TMDBAPIError: Decodable, Sendable {
    let statusMessage: String?

    enum CodingKeys: String, CodingKey {
        case statusMessage = "status_message"
    }
}

actor TMDBClient {
    static let live = TMDBClient()

    func homeSections() async throws -> [(MovieSection, [Movie])] {
        try await withThrowingTaskGroup(of: (MovieSection, [Movie]).self) { group in
            for section in MovieSection.homeSections {
                group.addTask {
                    let response: MovieListResponse = try await self.fetch(path: section.endpoint)
                    return (section, response.results)
                }
            }

            var loaded: [(MovieSection, [Movie])] = []
            for try await result in group {
                loaded.append(result)
            }

            return loaded.sorted { lhs, rhs in
                guard
                    let leftIndex = MovieSection.homeSections.firstIndex(of: lhs.0),
                    let rightIndex = MovieSection.homeSections.firstIndex(of: rhs.0)
                else {
                    return false
                }

                return leftIndex < rightIndex
            }
        }
    }

    func movieDetails(id: Int) async throws -> MovieDetails {
        try await fetch(
            path: "/movie/\(id)",
            queryItems: [URLQueryItem(name: "append_to_response", value: "credits,recommendations")]
        )
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let response: MovieListResponse = try await fetch(
            path: "/search/movie",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
        return response.results
    }

    private func fetch<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(url: TMDBConfiguration.apiBaseURL.appending(path: path), resolvingAgainstBaseURL: false)
        var resolvedQueryItems = queryItems
        resolvedQueryItems.append(URLQueryItem(name: "language", value: "en-US"))

        if TMDBConfiguration.authenticationMode == .apiKey {
            resolvedQueryItems.append(URLQueryItem(name: "api_key", value: TMDBConfiguration.rawCredential))
        }

        components?.queryItems = resolvedQueryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "accept")

        if TMDBConfiguration.authenticationMode == .bearerToken {
            request.setValue("Bearer \(TMDBConfiguration.rawCredential)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(TMDBAPIError.self, from: data)
            throw TMDBError.requestFailed(
                statusCode: httpResponse.statusCode,
                message: apiError?.statusMessage ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            )
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension EnvironmentValues {
    @Entry var tmdbClient: TMDBClient = .live
}
