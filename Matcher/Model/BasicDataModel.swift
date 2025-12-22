import Foundation

// MARK: - Root API Response
struct BasicDataModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: BasicDataContainer
}

// MARK: - Main Data Container
struct BasicDataContainer: Codable {
    let room: RoomData
    let gender: [OptionItem]
    let professionalField: [OptionItem]
    let intoParty: [OptionItem]

    enum CodingKeys: String, CodingKey {
        case room
        case gender
        case professionalField = "professional_field"
        case intoParty = "into_party"
    }
}

// MARK: - Room Section
struct RoomData: Codable {
    let roomType: [OptionItem]
    let amenities: [OptionItem]
    let furnishType: [OptionItem]

    enum CodingKeys: String, CodingKey {
        case roomType = "room_type"
        case amenities
        case furnishType = "furnish_type"
    }
}

// MARK: - Common Item Model
struct OptionItem: Codable, Identifiable {
    let id: Int
    let title: String
    let type: String
    let icon: String?
}
