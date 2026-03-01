protocol IconServiceProtocol {
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    )
}
