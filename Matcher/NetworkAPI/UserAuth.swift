//
//  UserAuth.swift
//  Attendance
//
//  Created by POSSIBILITY on 24/04/25.
//

import Foundation
import Combine

class UserAuth: ObservableObject {
    @Published var firstName: String = KeychainHelper.shared.get(forKey: "first_name") ?? ""
    @Published var email: String = KeychainHelper.shared.get(forKey: "email") ?? ""
    @Published var mobile: String = KeychainHelper.shared.get(forKey: "mobile") ?? ""
    @Published var gender: String = KeychainHelper.shared.get(forKey: "gender") ?? ""
    @Published var image: String = KeychainHelper.shared.get(forKey: "image") ?? ""
    @Published var steps: Bool {
        didSet {
            UserDefaults.standard.set(steps, forKey: "steps")
        }
    }
    @Published var space: Bool {
        didSet {
            UserDefaults.standard.set(space, forKey: "space")
        }
    }
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.steps = UserDefaults.standard.bool(forKey: "steps")
        self.space = UserDefaults.standard.bool(forKey: "space")
        print("steps =", self.steps)
        print("space =", self.space)
    }
    func login(email: String, password: String) {
        DispatchQueue.main.async {
            self.isLoggedIn = true
        }
    }
    func stepsComplete() {
        DispatchQueue.main.async {
            self.steps = true
        }
    }
    func spaceComplete() {
        DispatchQueue.main.async {
            self.space = true
        }
    }
    func logout() {
        KeychainHelper.shared.delete(forKey: "access_token")
        KeychainHelper.shared.delete(forKey: "image")
        KeychainHelper.shared.delete(forKey: "first_name")
        KeychainHelper.shared.delete(forKey: "email")
        KeychainHelper.shared.delete(forKey: "mobile")
        KeychainHelper.shared.delete(forKey: "gender")
        KeychainHelper.shared.delete(forKey: "steps")
        KeychainHelper.shared.delete(forKey: "space")
        self.steps = false
        self.space = false
        self.isLoggedIn = false
    }
}
