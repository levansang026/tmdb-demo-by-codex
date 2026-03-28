import Testing
@testable import TMDBNetflixFeature

@Test func movieReleaseYearUsesDatePrefix() async throws {
    let movie = Movie(
        id: 1,
        title: "Sample",
        overview: "Overview",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-03-28",
        voteAverage: 8.4,
        voteCount: 1200,
        genreIDs: [28]
    )

    #expect(movie.releaseYear == "2026")
}

@Test func detailsRuntimeFormatsHoursAndMinutes() async throws {
    let details = MovieDetails(
        id: 1,
        title: "Sample",
        overview: "Overview",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-03-28",
        runtime: 125,
        voteAverage: 8.4,
        genres: [],
        credits: nil,
        recommendations: nil
    )

    #expect(details.runtimeText == "2h 5m")
}
