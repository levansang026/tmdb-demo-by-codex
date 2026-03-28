import Foundation

struct Movie: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let genreIDs: [Int]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIDs = "genre_ids"
    }

    var releaseYear: String {
        releaseDate?.split(separator: "-").first.map(String.init) ?? "TBA"
    }

    var ratingText: String {
        String(format: "%.1f", voteAverage)
    }
}

struct MovieListResponse: Decodable, Sendable {
    let page: Int
    let results: [Movie]
}

struct MovieDetails: Decodable, Identifiable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let genres: [Genre]
    let credits: Credits?
    let recommendations: MovieListResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case genres
        case credits
        case recommendations
    }

    var ratingText: String {
        String(format: "%.1f", voteAverage)
    }

    var runtimeText: String {
        guard let runtime else { return "Runtime N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }

    var releaseYear: String {
        releaseDate?.split(separator: "-").first.map(String.init) ?? "TBA"
    }
}

struct Genre: Decodable, Hashable, Sendable {
    let id: Int
    let name: String
}

struct Credits: Decodable, Sendable {
    let cast: [CastMember]
}

struct CastMember: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}

struct MovieSection: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let endpoint: String

    static let homeSections: [MovieSection] = [
        .init(id: "trending", title: "Trending Now", endpoint: "/trending/movie/week"),
        .init(id: "popular", title: "Popular on TMDB", endpoint: "/movie/popular"),
        .init(id: "top-rated", title: "Top Rated", endpoint: "/movie/top_rated"),
        .init(id: "upcoming", title: "Upcoming", endpoint: "/movie/upcoming")
    ]
}
