import Foundation
// MARK: - Welcome
struct MessageModel: Codable {
    let success: Bool
    let status: Int
    let message: String
    let data: [Message]
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
    }
}
// MARK: - Datum
struct Message: Codable, Identifiable,Equatable {
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
