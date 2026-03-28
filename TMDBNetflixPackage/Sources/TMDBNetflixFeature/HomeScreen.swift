import SwiftUI

@MainActor
struct HomeScreen: View {
    @Environment(\.tmdbClient) private var tmdbClient
    @State private var sections: [(MovieSection, [Movie])] = []
    @State private var screenState: LoadState = .loading

    var body: some View {
        NavigationStack {
            Group {
                switch screenState {
                case .loading:
                    loadingView
                case let .failed(message):
                    ErrorStateView(message: message) {
                        await loadHome()
                    }
                case .loaded:
                    content
                }
            }
            .background(Color.black)
            .navigationBarHidden(true)
            .navigationDestination(for: Int.self) { movieID in
                MovieDetailScreen(movieID: movieID)
            }
        }
        .task {
            guard sections.isEmpty else { return }
            await loadHome()
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 28) {
                if let heroMovie = heroMovie {
                    HeroBanner(movie: heroMovie)
                }

                ForEach(sections, id: \.0.id) { section, movies in
                    if !movies.isEmpty {
                        CarouselRow(title: section.title, movies: movies)
                    }
                }

                Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 16)
        }
        .coordinateSpace(name: "homeScroll")
        .scrollIndicators(.hidden)
        .background(Color.black)
        .ignoresSafeArea(edges: .top)
    }

    private var heroMovie: Movie? {
        sections.first(where: { $0.0.id == "popular" })?.1.first
    }

    @ViewBuilder
    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 520)
                    .padding(.horizontal, 16)

                ForEach(0..<4, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 140, height: 18)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(0..<4, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 140, height: 210)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .redacted(reason: .placeholder)
        }
        .background(Color.black)
    }

    @MainActor
    private func loadHome() async {
        screenState = .loading

        do {
            sections = try await tmdbClient.homeSections()
            screenState = .loaded
        } catch is CancellationError {
            return
        } catch {
            screenState = .failed(error.localizedDescription)
        }
    }
}

private struct HeroBanner: View {
    let movie: Movie
    private let baseHeight: CGFloat = 560

    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("homeScroll")).minY
            let stretch = max(0, minY)

            NavigationLink(value: movie.id) {
                ZStack(alignment: .bottomLeading) {
                    TMDBImageView(path: movie.backdropPath ?? movie.posterPath, size: .backdrop, cornerRadius: 0)
                        .frame(width: proxy.size.width, height: baseHeight + stretch)
                        .offset(y: minY > 0 ? -minY : 0)
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.18), .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: baseHeight + stretch)
                            .offset(y: minY > 0 ? -minY : 0)
                        }

                    VStack(alignment: .leading, spacing: 16) {
                        header

                        Text(movie.title)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)

                        HStack(spacing: 10) {
                            Label(movie.ratingText, systemImage: "star.fill")
                            Text(movie.releaseYear)
                            Text("Movie")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.86))

                        Text(movie.overview)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.86))
                            .lineLimit(3)

                        HStack(spacing: 12) {
                            prominentButton(title: "My List", systemImage: "plus")
                            playStyleButton(title: "Details", systemImage: "info.circle.fill")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .frame(width: proxy.size.width, height: baseHeight, alignment: .bottom)
            }
            .buttonStyle(.plain)
        }
        .frame(height: baseHeight)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("NETFLIX-STYLE")
                .font(.caption.weight(.black))
                .tracking(2)
                .foregroundStyle(.red)

            Divider()
                .overlay(.white.opacity(0.3))
                .frame(height: 12)

            Text("Popular Pick")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private func prominentButton(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.12))
            .clipShape(.capsule)
    }

    private func playStyleButton(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white)
            .clipShape(.capsule)
    }
}

private struct CarouselRow: View {
    let title: String
    let movies: [Movie]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie.id) {
                            MoviePosterCard(movie: movie)
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

private struct MoviePosterCard: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TMDBImageView(path: movie.posterPath, size: .poster, cornerRadius: 16)
                .frame(width: 146, height: 220)
                .overlay(alignment: .topLeading) {
                    Text(movie.ratingText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(.capsule)
                        .padding(10)
                }

            Text(movie.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(movie.releaseYear)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 146, alignment: .leading)
    }
}
