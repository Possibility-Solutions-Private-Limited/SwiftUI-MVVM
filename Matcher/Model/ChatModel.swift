import Foundation
// MARK: - Welcome
struct ChatModel: Codable {
    let success: Bool
    let status: Int
    let message: String
    let data: chats
    let Users: [Users]?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
        case Users = "user"
    }
}
// MARK: - DataClass
struct chats: Codable {
    let data: [Chat]
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
// MARK: - Datum
struct Chat: Codable, Identifiable, Hashable {
    let id: Int
    let last: last?
    let senderID: Int
    let receiverID: Int
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let senderDetail: User?
    let receiverDetail: User?
    let unseen_message_count: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case last = "last_message"
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case senderDetail = "sender_detail"
        case receiverDetail = "receiver_detail"
        case unseen_message_count = "unseen_message_count"

    }
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
struct Users: Codable, Identifiable, Hashable {
    let id: Int?
    let image: String?
    let username: String?
    let first_name: String?
    let last_name: String?
    let email: String?
    let access_token: String?
    let mobile: String?
    let join_date: String?
    let gender: String?
    let designation: String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case username = "username"
        case first_name = "first_name"
        case last_name = "last_name"
        case email = "email"
        case access_token = "access_token"
        case mobile = "mobile"
        case join_date = "join_date"
        case gender = "gender"
        case designation = "designation"
    }
    static func == (lhs: Users, rhs: Users) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
struct last: Codable {
    let id: Int
    let sentby: Int
    let chat_id: Int
    let type: String?
    let message: String?
    let file: String?
    var isSeen: String
    enum CodingKeys: String, CodingKey {
        case id
        case sentby = "sent_by"
        case chat_id = "chat_id"
        case type = "type"
        case message = "message"
        case file = "file"
        case isSeen = "is_seen"
    }
}









