//
//  UserModel.swift
//  Attendance
//
//  Created by POSSIBILITY on 23/04/25.
//

import Foundation

struct UserModel: Codable {
    let message: String?
    let status: Int?
    let success: Bool
    let data: User?
    let token: String?
    let email: String?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case status = "status"
        case message = "message"
        case data = "data"
        case token = "token"
        case email = "email"
    }
}
struct User: Codable, Identifiable {
    let otp: Int?
    let id: Int?
    let first_name: String?
    let last_name: String?
    let email: String?
    let mobile: String?
    let gender: String?
    let dob: String?
    let photos: [photos]?
    let profile: String?
    enum CodingKeys: String, CodingKey {
        case otp = "otp"
        case id = "id"
        case first_name = "first_name"
        case last_name = "last_name"
        case email = "email"
        case mobile = "mobile"
        case gender = "gender"
        case dob = "dob"
        case photos = "photos"
        case profile = "profile"
    }
}
struct photos: Codable, Identifiable {
    let id: Int?
    let file: String?
    let file_type: String?
    let thumbnail: String?
    enum CodingKeys: String, CodingKey {
        case id
        case file = "file"
        case file_type = "file_type"
        case thumbnail = "thumbnail"
    }
}
