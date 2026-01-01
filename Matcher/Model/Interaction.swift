import Foundation

// MARK: - Root Response
struct Interaction: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: InteractionData
}
struct InteractionData: Codable {
    let interacted_user: [InteractedUser]
}
struct InteractedUser: Codable, Identifiable {
    var id: Int { intraction_id }
    let intraction_id: Int
    let user: Profiles?
}
