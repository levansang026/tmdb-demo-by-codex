import SwiftUI
import NukeUI

enum TMDBImageSize: String {
    case poster = "w500"
    case backdrop = "w1280"
    case profile = "w185"
}

struct TMDBImageView: View {
    let path: String?
    let size: TMDBImageSize
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if let url {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if state.error != nil {
                        placeholder
                    } else {
                        ZStack {
                            placeholder
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
    }

    private var url: URL? {
        guard let path else { return nil }
        return TMDBConfiguration.imageBaseURL.appending(path: "\(size.rawValue)\(path)")
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "film.stack.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
