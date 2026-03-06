import Foundation

struct FreepikResponse: Codable {
    let data: [FreepikIcon]
    let meta: Meta
}

struct FreepikIcon: Codable {
    let id: Int
    let name: String
    let thumbnails: [FreepikThumbnail]
    let tags: [FreepikTag]
}

struct FreepikThumbnail: Codable {
    let url: URL
}

struct FreepikTag: Codable {
    let name: String
}

struct Meta: Codable {
    let pagination: Pagination
}

struct Pagination: Codable {
    let total: Int
}
