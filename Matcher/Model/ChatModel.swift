import Foundation

struct ChatModel: Codable {
    let success: Bool
    let status: Int
    let message: String
    let data: [Chat]
    let users: [Users]?
    enum CodingKeys: String, CodingKey {
        case success
        case status
        case message
        case data
        case users = "users"
    }
}
struct Users: Codable, Identifiable, Hashable {
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
    let rooms: [Room]?

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
        case rooms
    }
    static func == (lhs: Users, rhs: Users) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
struct Chat: Codable, Identifiable, Hashable {
    let id: Int
    let senderDetail: User
    let receiverDetail: User
    let lastMessage: LastMessage?
    let createdAt: String
    let unseen_message_count : Int?
    enum CodingKeys: String, CodingKey {
        case id
        case senderDetail = "sender"
        case receiverDetail = "receiver"
        case lastMessage = "last_message"
        case createdAt = "created_at"
        case unseen_message_count = "unseen_message_count"
    }
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
struct LastMessage: Codable {
    let id: Int
    let message: String?
    let file: String?
    let type: String?
    let isSeen: String
    let createdAt: String
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case file
        case type
        case isSeen = "is_seen"
        case createdAt = "created_at"
    }
}
