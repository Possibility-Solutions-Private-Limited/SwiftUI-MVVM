//
//  APIConstants.swift
//  Attendance
//
//  Created by POSSIBILITY on 23/04/25.
//

import Foundation

struct APIConstants {
    static let baseURL = "http://192.168.31.46:8000/api/v1/"
    static let socketURL = "http://192.168.31.46:3000"
    struct Endpoints {
        static let login = "login"
        static let Sociallogin = "social-login"
        static let SignUp = "signup"
        static let verifyOTP = "verify-otp"
        static let StepOne = "profile/step/1"
        static let BasicData = "basic-data"
        static let StepTwo = "profile/step/2"
        static let AddRoom = "profile/add-room"
        static let EditRoom = "profile/update-room"
        static let Profile = "profile"
        static let Update = "profile/update"
        static let Delete = "delete"
        static let Logout = "logout"
        static let sendOTP = "send-otp"
        static let verifyForgotOTP = "verify-forgot-otp"
        static let ChangePassword = "change-password"
        static let chatUser = "users"
        static let chatlist = "chat-list"
        static let dashboard = "dashboard?"
        static let like = "interaction/like/"
        static let dislike = "interaction/dislike/"
        static let interaction = "interaction"
        static let notification = "notification"
        static let notificationDelete = "notification/delete"
        static let notificationSettings = "notification/settings"
        static let helpSupport = "help-support"
        static let faqs = "faqs"
        static let Terms = "terms-conditions"
        static let Privacy = "privacy-policy"
    }
}
