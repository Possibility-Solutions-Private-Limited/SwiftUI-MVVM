import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var validator = ValidationHelper()
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @FocusState private var focusedField: Field?
    enum Field {
        case newPassword
        case confirmPassword
    }
    @StateObject private var CHANGE = ChangeForgotModel()
    @State private var isUploading = false
    @Binding var goToVerifyOTP: Bool
    @Binding var goToChangePassword: Bool
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.textPrimary)
                               passwordField(
                                placeholder: "Enter New Password",
                                text: $newPassword,
                                isSecure: !showNewPassword,
                                toggle: { showNewPassword.toggle() },
                                field: .newPassword,
                                submitLabel: .next,
                                onSubmit: {
                                    focusedField = .confirmPassword
                                }
                            )
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.textPrimary)
                              passwordField(
                                placeholder: "Enter Confirm Password",
                                text: $confirmPassword,
                                isSecure: !showConfirmPassword,
                                toggle: { showConfirmPassword.toggle() },
                                field: .confirmPassword,
                                submitLabel: .done,
                                onSubmit: {
                                    focusedField = nil
                                    validateAndSubmit()
                                }
                            )
                        }
                        Button(action: validateAndSubmit) {
                            Text("Update Password")
                                .font(AppFont.manropeSemiBold(16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryYellow)
                                .cornerRadius(14)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
    }
    // MARK: - Password Field
    private func passwordField(
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        toggle: @escaping () -> Void,
        field: Field,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(AppColors.textGray)
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(AppFont.manrope(14))
            .focused($focusedField, equals: field)
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(.newPassword)

            Button(action: toggle) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(AppColors.textGray)
            }
        }
        .padding()
        .background(Color.lightYellow)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.borderGray)
        )
        .cornerRadius(12)
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
        print(param)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        goToChangePassword = false
                        goToVerifyOTP = false
                    }
                }
            }else {
                isUploading = false
            }
        }
    }
}
