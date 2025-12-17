//
//  UserAuth.swift
//  Attendance
//
//  Created by POSSIBILITY on 24/04/25.
//

import Foundation

class UserAuth: ObservableObject {
    @Published var firstName: String = KeychainHelper.shared.get(forKey: "first_name") ?? ""
    @Published var email: String = KeychainHelper.shared.get(forKey: "email") ?? ""
    @Published var mobile: String = KeychainHelper.shared.get(forKey: "mobile") ?? ""
    @Published var gender: String = KeychainHelper.shared.get(forKey: "gender") ?? ""
    @Published var image: String = KeychainHelper.shared.get(forKey: "image") ?? ""
    @Published var isLoggedIn: Bool {
     didSet {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
      }
    }
    init() {
      self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    func login(email: String, password: String) {
        self.isLoggedIn = true
    }
    func logout() {
        KeychainHelper.shared.delete(forKey: "access_token")
        KeychainHelper.shared.delete(forKey: "image")
        KeychainHelper.shared.delete(forKey: "first_name")
        KeychainHelper.shared.delete(forKey: "email")
        KeychainHelper.shared.delete(forKey: "mobile")
        KeychainHelper.shared.delete(forKey: "gender")
        self.isLoggedIn = false
    }
}

