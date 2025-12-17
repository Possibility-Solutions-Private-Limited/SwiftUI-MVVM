import Foundation
import SwiftUI

final class ValidationHelper: ObservableObject {
    // MARK: - Toast State
    @Published var showToast: Bool = false
    @Published var validationMessage: String = ""
    // MARK: - Show Toast
    func showValidation(_ message: String) {
        validationMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
    // MARK: - Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    // MARK: - Password Validation
    func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
    // MARK: - Mobile Validation
    func isValidMobile(_ mobile: String) -> Bool {
        let regex = #"^[0-9]{10}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: mobile)
    }
    // MARK: - Name Validation
    func isValidName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    // MARK: - OTP Validation
    func isValidOTP(_ otp: String) -> Bool {
        let regex = #"^[0-9]{6}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: otp)
    }
    // MARK: - Empty Field
    func isNotEmpty(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
struct AppFont {
    static func manrope(_ size: CGFloat) -> Font {
        .custom("Manrope-Regular", size: size)
    }
    static func manropeMedium(_ size: CGFloat) -> Font {
        .custom("Manrope-Medium", size: size)
    }
    static func manropeSemiBold(_ size: CGFloat) -> Font {
        .custom("Manrope-SemiBold", size: size)
    }
    static func manropeBold(_ size: CGFloat) -> Font {
        .custom("Manrope-Bold", size: size)
    }
}
struct AppColors {
    static let primaryYellow = Color.yellow.opacity(0.9)
    static let borderGray = Color.gray.opacity(0.3)
    static let backgroundWhite = Color.white
    static let textBlack = Color.black
    static let textGray = Color.gray
}
struct ValidationMessages {
    static let emailEmpty = "Please enter your email address."
    static let emailInvalid = "Please enter a valid email address."
    static let passwordEmpty = "Please enter your password."
    static let passwordTooShort = "Password must be at least 6 characters long."
    static let phoneEmpty = "Please enter your email address."
    static let phoneInvalid = "Please enter your valid phone number."
    static let firstNameEmpty = "Please enter your first name."
    static let lastNameEmpty = "Please enter your last name."
    static let confirmPasswordEmpty = "Please confirm your password."
    static let passwordMismatch = "Passwords do not match."
}
extension Color {
    static let splashTop = Color(hex: "#F4F4F4")
    static let splashBottom = Color(hex: "#FFE7A3")
    static let primaryYellow = Color(hex: "#FFE55C")
    static let textPrimary = Color.black
    static let derkYellow = Color.yellow.opacity(0.08)
    static let lightYellow = Color.yellow.opacity(0.05)
    static let cardBackground = Color.white
}
extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

