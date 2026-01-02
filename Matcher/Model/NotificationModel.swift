import Foundation

// MARK: - Root Response
struct NotificationModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [NotificationData]
}
// MARK: - DashboardData
struct NotificationData: Codable, Identifiable {
    let id: Int
    let userID: Int
    let message: String
    let type: String
    let data: String
    let isSeen: String
    let isRead: String
    let senderDetail: SenderDetail
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case message
        case type
        case data
        case isSeen = "is_seen"
        case isRead = "is_read"
        case senderDetail = "sender_detail"
    }
}
struct SenderDetail: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let mobile: String
    let gender: String
    let dob: String
    let lat: String?
    let long: String?
    let location: String?
    let pageKey: Int
    let photos: [UserPhoto]
    let profile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case mobile
        case gender
        case dob
        case lat
        case long
        case location
        case pageKey = "page_key"
        case photos
        case profile
    }
}
struct UserPhoto: Codable, Identifiable {
    let id: Int
    let file: String
    let fileType: String
    let thumbnail: String

    enum CodingKeys: String, CodingKey {
        case id
        case file
        case fileType = "file_type"
        case thumbnail
    }
}
struct UserProfile: Codable, Identifiable {
    let id: Int
    let userID: Int
    let describeYouBest: String?
    let professionalField: Int?
    let workShift: String?
    let foodPreference: String?
    let intoParties: Int?
    let smoking: String?
    let drinking: String?
    let aboutYourself: String?
    let doYouHaveRoom: String?
    let wantLiveWith: Int?
    let professionalFieldData: MetaData?
    let intoPartiesData: MetaData?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case describeYouBest = "describe_you_best"
        case professionalField = "professional_field"
        case workShift = "work_shift"
        case foodPreference = "food_preference"
        case intoParties = "into_parties"
        case smoking
        case drinking
        case aboutYourself = "about_yourself"
        case doYouHaveRoom = "do_you_have_room"
        case wantLiveWith = "want_live_with"
        case professionalFieldData = "professional_field_data"
        case intoPartiesData = "into_parties_data"
    }
}
struct MetaData: Codable, Identifiable {
    let id: Int
    let title: String
    let type: String
    let icon: String?
}
