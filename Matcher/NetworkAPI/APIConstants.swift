//
//  APIConstants.swift
//  Attendance
//
//  Created by POSSIBILITY on 23/04/25.
//

import Foundation

struct APIConstants {
    static let baseURL = "http://172.20.10.2:8080/api/v1/"
    static let socketURL = "http://172.20.10.2:3000"
    struct Endpoints {
        static let login = "login"
        static let Sociallogin = "social-login"
        static let SignUp = "signup"
        static let verifyOTP = "verify-otp"
        static let StepOne = "profile/step/1"
        static let BasicData = "basic-data"
        static let StepTwo = "profile/step/2"
        static let AddRoom = "profile/add-room"
        static let sendOTP = "send-otp"
        static let verifyForgotOTP = "verify-forgot-otp"
        static let ChangePassword = "change-password"
        static let chatUser = "users"
        static let chatlist = "chat-list"
    
        static let dashboard = "dashboard?"

    }
}
