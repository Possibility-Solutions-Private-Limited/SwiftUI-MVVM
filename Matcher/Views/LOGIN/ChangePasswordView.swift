import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var validator = ValidationHelper()
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = true
    @State private var showConfirmPassword = true
    @FocusState private var focusedField: Field?
    enum Field {
        case newPassword
        case confirmPassword
    }
    @StateObject private var CHANGE = ChangeForgotModel()
    @State private var isUploading = false
    @Binding var goToVerifyOTP: Bool
    @Binding var goToChangePassword: Bool
    @Binding var goToForgotView: Bool
    let email: String
    let otp: String
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [.derkYellow, .lightYellow],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Image("login_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 380)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .ignoresSafeArea(edges: .top)
                VStack {
                    Spacer().frame(height: 200)
                   VStack(alignment: .leading, spacing: 20) {
                        Text("Change Password")
                            .font(AppFont.manropeSemiBold(22))
                            .foregroundColor(.textPrimary)
                        Text("Create a strong password to keep your account secure.")
                            .font(AppFont.manrope(13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 10)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack(alignment: .leading) {
                            Text("New Password")
                                .font(AppFont.manropeSemiBold(14))
                                HStack {
                                    Image("lock")
                                    NoAssistantTextField(
                                        text: $newPassword,
                                        isSecure: $showNewPassword,
                                        placeholder: "Enter New Password",
                                        fieldType: .Password,
                                        returnKeyType: .next,
                                        onCommit: { focusedField = .confirmPassword }
                                    )
                                    .focused($focusedField, equals: .newPassword)
                                    Button {
                                        showNewPassword.toggle()
                                    } label: {
                                        Image(systemName: showNewPassword ? "eye" : "eye.slash")
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(height: 55)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.3))
                                    )
                        }
                       
                       VStack(alignment: .leading) {
                           Text("Confirm Password")
                               .font(AppFont.manropeSemiBold(14))
                               HStack {
                                   Image("lock")
                                   NoAssistantTextField(
                                       text: $confirmPassword,
                                       isSecure: $showConfirmPassword,
                                       placeholder: "Enter Confirm Password",
                                       fieldType: .Password,
                                       returnKeyType: .done,
                                       onCommit: { focusedField = nil }
                                   )
                                   .focused($focusedField, equals: .confirmPassword)
                                   Button {
                                       showConfirmPassword.toggle()
                                   } label: {
                                       Image(systemName: showConfirmPassword ? "eye" : "eye.slash")
                                           .foregroundColor(.black)
                                   }
                               }
                               .frame(height: 55)
                                   .padding(.horizontal)
                                   .background(
                                       RoundedRectangle(cornerRadius: 15)
                                           .stroke(Color.gray.opacity(0.3))
                                   )
                        }
                       Button(action: validateAndSubmit) {
                           ZStack {
                               RoundedRectangle(cornerRadius: 16)
                                   .fill(AppColors.primaryYellow)
                                   .frame(height: 50)
                               HStack(spacing: 8) {
                                   if isUploading {
                                       ProgressView()
                                           .progressViewStyle(
                                               CircularProgressViewStyle(tint: .black)
                                           )
                                   }
                                   Text("Update Password")
                                       .font(AppFont.manropeMedium(16))
                                       .foregroundColor(.black)
                               }
                           }
                       }
                       .frame(maxWidth: .infinity)
                       .padding(.top, 10)
                       .allowsHitTesting(!isUploading)
                       .opacity(isUploading ? 0.7 : 1)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = .newPassword
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
    }
    // MARK: - Validation
    private func validateAndSubmit() {
        if !validator.isNotEmpty(newPassword) {
            validator.showValidation(ValidationMessages.passwordEmpty)
            return
        }
        if !validator.isValidPassword(newPassword) {
            validator.showValidation(ValidationMessages.passwordTooShort)
            return
        }
        if !validator.isNotEmpty(confirmPassword) {
            validator.showValidation(ValidationMessages.confirmPasswordEmpty)
            return
        }
        if newPassword != confirmPassword {
            validator.showValidation(ValidationMessages.passwordMismatch)
            return
        }
        isUploading = true
        let param: [String: Any] = [
            "email": email,
            "otp": otp,
            "password":newPassword
        ]
        CHANGE.ChangeForgotAPI(param: param) { response in
            guard let response else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
                return
            }
            validator.showValidation(response.message ?? "")
            validator.showToast = true
            if response.success {
                DispatchQueue.main.async {
                    isUploading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        goToChangePassword = false
                        goToVerifyOTP = false
                        goToForgotView = false
                    }
                }
            }else {
                isUploading = false
            }
        }
    }
}
