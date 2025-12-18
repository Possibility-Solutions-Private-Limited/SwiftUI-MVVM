//
//  APIConstants.swift
//  Attendance
//
//  Created by POSSIBILITY on 23/04/25.
//

import Foundation

struct APIConstants {
    static let baseURL = "http://192.168.31.46:8080/api/v1/"
    static let socketURL = "http://192.168.31.46:3000"
    struct Endpoints {
        static let login = "login"
        static let Sociallogin = "social-login"
        static let SignUp = "signup"
        static let verifyOTP = "verify-otp"
        static let StepOne = "profile/step/1"
        static let sendOTP = "send-otp"
        static let verifyForgotOTP = "verify-forgot-otp"
        static let ChangePassword = "change-password"

        static let chatUser = "users"
        static let chatlist = "chat-list"
    }
}
