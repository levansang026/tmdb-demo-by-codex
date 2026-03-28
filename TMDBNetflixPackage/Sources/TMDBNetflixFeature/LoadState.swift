enum LoadState: Sendable {
    case loading
    case loaded
    case failed(String)
}
