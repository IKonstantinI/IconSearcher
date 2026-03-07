import Foundation

struct FreepikResponse: Codable {
    let data: [FreepikIcon]
    let meta: Meta
}

struct Meta: Codable {
    let pagination: Pagination
}

struct Pagination: Codable {
    let total: Int
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    
    enum CodingKeys: String, CodingKey {
        case total
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
    }
}

struct FreepikIcon: Codable {
    let id: Int
    let name: String
    let tags: [FreepikTag]?
    let thumbnails: [FreepikThumbnail]
}

struct FreepikTag: Codable {
    let name: String
    let slug: String
}

struct FreepikThumbnail: Codable {
    let url: URL
    let width: Int
    let height: Int
}
