import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retry: @Sendable () async -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)

            Text("Unable to load movies")
                .font(.title3.weight(.heavy))
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await retry()
                }
            }
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(.capsule)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
