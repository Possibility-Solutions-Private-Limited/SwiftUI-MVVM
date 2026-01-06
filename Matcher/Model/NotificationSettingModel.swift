//
//  NotificationSettingModel.swift
//  Matcher
//
//  Created by POSSIBILITY on 06/01/26.
//

import Foundation
struct NotificationSettingModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    let data: notificationSetting?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
    }
}
struct notificationSetting: Codable, Identifiable {
    let id: Int?
    let user_id: Int?
    let all_notifications: Bool?
    let chat_alerts: Bool?
    let post_likes: Bool?
    let new_message_alerts: Bool?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case user_id = "user_id"
        case all_notifications = "all_notifications"
        case chat_alerts = "chat_alerts"
        case post_likes = "post_likes"
        case new_message_alerts = "new_message_alerts"
    }
}

