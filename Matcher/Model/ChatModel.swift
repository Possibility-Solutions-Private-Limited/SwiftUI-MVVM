import Foundation

struct ChatModel: Codable {
    let success: Bool
    let status: Int
    let message: String
    let data: [Chat]
    enum CodingKeys: String, CodingKey {
        case success
        case status
        case message
        case data
    }
}
final class Chat: ObservableObject, Identifiable, Hashable, Codable {
    let id: Int
    let senderDetail: User
    let receiverDetail: User
    @Published var lastMessage: LastMessage?
    @Published var createdAt: String
    @Published var unseen_message_count: Int?
    enum CodingKeys: String, CodingKey {
        case id
        case senderDetail = "sender"
        case receiverDetail = "receiver"
        case lastMessage = "last_message"
        case createdAt = "created_at"
        case unseen_message_count
    }
    init(
        id: Int,
        senderDetail: User,
        receiverDetail: User,
        lastMessage: LastMessage?,
        createdAt: String,
        unseen_message_count: Int?
    ) {
        self.id = id
        self.senderDetail = senderDetail
        self.receiverDetail = receiverDetail
        self.lastMessage = lastMessage
        self.createdAt = createdAt
        self.unseen_message_count = unseen_message_count
    }
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.senderDetail = try container.decode(User.self, forKey: .senderDetail)
        self.receiverDetail = try container.decode(User.self, forKey: .receiverDetail)
        self.lastMessage = try container.decodeIfPresent(LastMessage.self, forKey: .lastMessage)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.unseen_message_count = try container.decodeIfPresent(Int.self, forKey: .unseen_message_count)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(senderDetail, forKey: .senderDetail)
        try container.encode(receiverDetail, forKey: .receiverDetail)
        try container.encode(lastMessage, forKey: .lastMessage)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(unseen_message_count, forKey: .unseen_message_count)
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
