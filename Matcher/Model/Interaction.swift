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
struct InteractedUser: Identifiable, Hashable, Codable {
    var id: Int { intraction_id }
    let intraction_id: Int
    var user: Profiles?
    static func == (lhs: InteractedUser, rhs: InteractedUser) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

