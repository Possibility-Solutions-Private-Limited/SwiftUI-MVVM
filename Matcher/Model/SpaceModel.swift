import Foundation

struct SpaceModel: Codable {
    let status: Int?
    let success: Bool
    let message: String?
    let data: [Room]?
}
struct Room: Codable, Identifiable {
    let id: Int?
    let userID: Int?
    let amenities: [Amenity]?
    let roomType: String?
    let roomMateWant: Int?
    let rentSplit: String?
    let furnishType: String?
    let wantToLiveWith: String?
    let location: String?
    let lat: String?
    let long: String?
    let photos: [Photos]?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userID = "user_id"
        case amenities = "amenities"
        case roomType = "room_type"
        case roomMateWant = "room_mate_want"
        case rentSplit = "rent_split"
        case furnishType = "furnish_type"
        case wantToLiveWith = "want_to_live_with"
        case location = "location"
        case lat = "lat"
        case long = "long"
        case photos = "photos"
    }
}
struct Amenity: Codable, Identifiable {
    let id: Int?
    let title: String?
    let icon: String?
}
struct Photos: Codable, Identifiable {
    let id: Int?
    let file: String?
    let fileType: String?
    let thumbnail: String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case file = "file"
        case thumbnail = "thumbnail"
        case fileType = "file_type"
    }
}
