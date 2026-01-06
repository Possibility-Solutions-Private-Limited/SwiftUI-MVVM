//
//  FAQsModel.swift
//  Matcher
//
//  Created by POSSIBILITY on 06/01/26.
//
import Foundation

struct FAQModel: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [FAQ]
}
struct FAQ: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
}
