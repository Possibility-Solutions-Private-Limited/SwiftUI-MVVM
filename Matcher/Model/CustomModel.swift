//
//  CustomModel.swift
//  Matcher
//
//  Created by POSSIBILITY on 29/12/25.
//

import Foundation
struct CustomModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
    }
}
