import SwiftUI

public struct TMDBNetflixRootView: View {
    public init() {}

    public var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeScreen()
            }

            Tab("Search", systemImage: "magnifyingglass") {
                SearchScreen()
            }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .environment(\.tmdbClient, TMDBClient.live)
    }
}
