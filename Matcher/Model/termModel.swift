//
//  termModel.swift
//  Matcher
//
//  Created by POSSIBILITY on 06/01/26.
//

struct termModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    let data: termData?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
    }
}
struct termData: Codable {
    let termPolicy: String?
    enum CodingKeys: String, CodingKey {
        case termPolicy = "terms_conditions"
    }
}
