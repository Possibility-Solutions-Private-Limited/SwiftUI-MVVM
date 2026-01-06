//
//  privacyModel.swift
//  Matcher
//
//  Created by POSSIBILITY on 06/01/26.
//

import Foundation

struct privacyModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    let data: PrivacyData?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
    }
}
struct PrivacyData: Codable {
    let privacyPolicy: String?
    enum CodingKeys: String, CodingKey {
        case privacyPolicy = "privacy_policy"
    }
}
