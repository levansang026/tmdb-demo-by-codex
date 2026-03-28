import SwiftUI

@MainActor
struct MovieDetailScreen: View {
    @Environment(\.tmdbClient) private var tmdbClient
    let movieID: Int

    @State private var details: MovieDetails?
    @State private var screenState: LoadState = .loading

    var body: some View {
        Group {
            switch screenState {
            case .loading:
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            case let .failed(message):
                ErrorStateView(message: message) {
                    await loadDetails()
                }
            case .loaded:
                if let details {
                    detailContent(details)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task(id: movieID) {
            await loadDetails()
        }
    }

    private func detailContent(_ details: MovieDetails) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GeometryReader { proxy in
                    ZStack(alignment: .bottomLeading) {
                        TMDBImageView(path: details.backdropPath ?? details.posterPath, size: .backdrop, cornerRadius: 0)
                            .frame(width: proxy.size.width, height: 380)
                            .overlay {
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.2), .black],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }

                        VStack(alignment: .leading, spacing: 14) {
                            Text(details.title)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundStyle(.white)

                            HStack(spacing: 10) {
                                Label(details.ratingText, systemImage: "star.fill")
                                Text(details.releaseYear)
                                Text(details.runtimeText)
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.82))

                            HStack(spacing: 12) {
                                detailButton(title: "Add to List", systemImage: "plus")
                                detailButton(title: "Share", systemImage: "paperplane.fill")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 22)
                    }
                    .frame(width: proxy.size.width, height: 380)
                }
                .frame(height: 380)

                VStack(alignment: .leading, spacing: 18) {
                    if !details.genres.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(details.genres, id: \.id) { genre in
                                    Text(genre.name)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white.opacity(0.88))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.white.opacity(0.09))
                                        .clipShape(.capsule)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .scrollIndicators(.hidden)
                    }

                    Text("Overview")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)

                    Text(details.overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 20)

                    if let cast = details.credits?.cast.prefix(10), !cast.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Cast")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 14) {
                                    ForEach(Array(cast)) { person in
                                        VStack(alignment: .leading, spacing: 10) {
                                            TMDBImageView(path: person.profilePath, size: .profile, cornerRadius: 16)
                                                .frame(width: 110, height: 136)

                                            Text(person.name)
                                                .font(.subheadline.weight(.bold))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)

                                            Text(person.character ?? "Cast")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.6))
                                                .lineLimit(2)
                                        }
                                        .frame(width: 110, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollIndicators(.hidden)
                        }
                    }

                    if let recommendations = details.recommendations?.results, !recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("More Like This")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 14) {
                                    ForEach(recommendations.prefix(12)) { movie in
                                        NavigationLink(value: movie.id) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                TMDBImageView(path: movie.posterPath, size: .poster, cornerRadius: 16)
                                                    .frame(width: 146, height: 220)

                                                Text(movie.title)
                                                    .font(.subheadline.weight(.bold))
                                                    .foregroundStyle(.white)
                                                    .lineLimit(2)
                                            }
                                            .frame(width: 146, alignment: .leading)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                }

                Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .top)
        .navigationDestination(for: Int.self) { nextID in
            MovieDetailScreen(movieID: nextID)
        }
    }

    private func detailButton(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white.opacity(0.12))
            .clipShape(.capsule)
    }

    @MainActor
    private func loadDetails() async {
        screenState = .loading

        do {
            details = try await tmdbClient.movieDetails(id: movieID)
            screenState = .loaded
        } catch is CancellationError {
            return
        } catch {
            screenState = .failed(error.localizedDescription)
        }
    }
}
