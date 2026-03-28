import SwiftUI

@MainActor
struct SearchScreen: View {
    @State private var query = ""
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.18, green: 0.02, blue: 0.03), .black, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Find movies, explore the catalog, and jump straight into a cinematic detail page.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    searchField

                    Text("Popular searches")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(.white)

                    FlowLayout(spacing: 10, lineSpacing: 10) {
                        ForEach(sampleQueries, id: \.self) { term in
                            Button(term) {
                                query = term
                                submitSearch()
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.1))
                            .clipShape(.capsule)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case let .results(query):
                    SearchResultsScreen(query: query)
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.7))

            TextField("Search movies", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)
                .onSubmit {
                    submitSearch()
                }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.08))
        .clipShape(.rect(cornerRadius: 18))
        .overlay(alignment: .trailing) {
            Button("Go") {
                submitSearch()
            }
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white)
            .clipShape(.capsule)
            .padding(.trailing, 8)
        }
    }

    private func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        path.append(SearchRoute.results(trimmed))
    }
}

private enum SearchRoute: Hashable {
    case results(String)
}

private let sampleQueries = [
    "Dune",
    "Inception",
    "The Batman",
    "Interstellar",
    "Parasite",
    "Spider-Man"
]

@MainActor
private struct SearchResultsScreen: View {
    @Environment(\.tmdbClient) private var tmdbClient
    let query: String

    @State private var movies: [Movie] = []
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
                    await loadResults()
                }
            case .loaded:
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie.id) {
                                HStack(spacing: 14) {
                                    TMDBImageView(path: movie.posterPath, size: .poster, cornerRadius: 16)
                                        .frame(width: 110, height: 160)

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(movie.title)
                                            .font(.headline.weight(.heavy))
                                            .foregroundStyle(.white)

                                        HStack(spacing: 10) {
                                            Label(movie.ratingText, systemImage: "star.fill")
                                            Text(movie.releaseYear)
                                        }
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white.opacity(0.7))

                                        Text(movie.overview)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.7))
                                            .lineLimit(4)
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .background(.white.opacity(0.06))
                                .clipShape(.rect(cornerRadius: 20))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
                .background(Color.black)
            }
        }
        .navigationTitle(query)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Int.self) { movieID in
            MovieDetailScreen(movieID: movieID)
        }
        .task(id: query) {
            await loadResults()
        }
    }

    @MainActor
    private func loadResults() async {
        screenState = .loading

        do {
            movies = try await tmdbClient.searchMovies(query: query)
            screenState = .loaded
        } catch is CancellationError {
            return
        } catch {
            screenState = .failed(error.localizedDescription)
        }
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat
    let lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var cursor = CGPoint.zero
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursor.x + size.width > maxWidth, cursor.x > 0 {
                cursor.x = 0
                cursor.y += rowHeight + lineSpacing
                totalHeight += rowHeight + lineSpacing
                rowHeight = 0
            }

            rowHeight = max(rowHeight, size.height)
            cursor.x += size.width + spacing
        }

        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var cursor = CGPoint(x: bounds.minX, y: bounds.minY)
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursor.x + size.width > bounds.maxX, cursor.x > bounds.minX {
                cursor.x = bounds.minX
                cursor.y += rowHeight + lineSpacing
                rowHeight = 0
            }

            subview.place(at: cursor, proposal: ProposedViewSize(width: size.width, height: size.height))
            cursor.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
