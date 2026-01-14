import Foundation

// MARK: - DashboardResponse
struct DashboardResponse: Codable {
    let status: Int?
    let success: Bool?
    let message: String?
    let data: DashboardData?
}

// MARK: - DashboardData
struct DashboardData: Codable {
    let profiles: [Profiles]?
    let meta: DashboardMeta?
    let links: DashboardLinks?
}

// MARK: - Profiles
struct Profiles: Codable, Identifiable {
    let id: Int?
    let first_name, last_name, email, mobile: String?
    let gender, dob: String?
    let lat, long, location: String?
    let page_key: Int?
    let photos: [Photo]?
    let chatting: Chatting?
    let profile: ProfileDetail?
    let rooms: [Room]?
}

// MARK: - ProfileDetail
struct ProfileDetail: Codable {
    let id, user_id: Int?
    let describe_you_best: String?
    let professional_field: Int?
    let work_shift, food_preference: String?
    let into_parties: Int?
    let smoking, drinking: String?
    let about_yourself, do_you_have_room: String?
    let want_live_with: Int?
    let professional_field_data: ProfessionalFieldData?
    let into_parties_data: IntoPartiesData?

    enum CodingKeys: String, CodingKey {
        case id, user_id, describe_you_best, professional_field, work_shift, food_preference
        case into_parties, smoking, drinking, about_yourself, do_you_have_room, want_live_with
        case professional_field_data = "professional_field_data"
        case into_parties_data = "into_parties_data"
    }
}

// MARK: - ProfessionalFieldData
struct ProfessionalFieldData: Codable {
    let id: Int?
    let title, type: String?
    let icon: String?
}

// MARK: - IntoPartiesData
struct IntoPartiesData: Codable {
    let id: Int?
    let title, type: String?
    let icon: String?
}





// MARK: - DashboardMeta
struct DashboardMeta: Codable {
    let current_page, last_page, per_page, total: Int?
}

// MARK: - DashboardLinks
struct DashboardLinks: Codable {
    let first, last: String?
    let prev, next: String?
}
