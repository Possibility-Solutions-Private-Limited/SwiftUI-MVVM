import Foundation
struct UserModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    let data: User?
    let token: String?
    let email: String?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
        case token = "token"
        case email = "email"
    }
}
struct User: Codable, Identifiable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let email: String?
    let mobile: String?
    let gender: String?
    let dob: String?
    let lat: String?
    let long: String?
    let location: String?
    let pageKey: Int?
    let photos: [Photo]?
    let profile: Profile?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case mobile = "mobile"
        case gender = "gender"
        case dob = "dob"
        case lat = "lat"
        case long = "long"
        case location = "location"
        case pageKey = "page_key"
        case photos = "photos"
        case profile = "profile"
    }
}
struct Photo: Codable, Identifiable {
    let id: Int?
    let file: String?
    let fileType: String?
    let thumbnail: String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case file = "file"
        case fileType = "file_type"
        case thumbnail = "thumbnail"
    }
}
struct Profile: Codable, Identifiable {
    let id: Int?
    let userId: Int?
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
    let professionalFieldData: FieldData?
    let intoPartiesData: FieldData?
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case describeYouBest = "describe_you_best"
        case professionalField = "professional_field"
        case workShift = "work_shift"
        case foodPreference = "food_preference"
        case intoParties = "into_parties"
        case smoking = "smoking"
        case drinking = "drinking"
        case aboutYourself = "about_yourself"
        case doYouHaveRoom = "do_you_have_room"
        case wantLiveWith = "want_live_with"
        case professionalFieldData = "professional_field_data"
        case intoPartiesData = "into_parties_data"
    }
}
struct FieldData: Codable, Identifiable {
    let id: Int?
    let title: String?
    let type: String?
    let icon: String?
}
