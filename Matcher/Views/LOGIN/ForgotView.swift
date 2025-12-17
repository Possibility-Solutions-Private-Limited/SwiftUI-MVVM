import SwiftUI

struct ForgotView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @StateObject private var validator = ValidationHelper()
    @StateObject private var FORGOT = ForgotModel()
    @State private var goToVerifyOTP = false
    @Binding var goToForgotView: Bool
    @State private var isUploading = false
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
                    .clipShape(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                    )
                    .ignoresSafeArea(edges: .top)
                 VStack {
                    Spacer().frame(height: 200)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Forgot Password")
                            .font(AppFont.manropeSemiBold(22))
                        Text("Please enter your registered email address. We will send you a password reset link.")
                            .font(AppFont.manrope(14))
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(AppFont.manropeSemiBold(13))
                            HStack {
                                Image("mail")
                                NoAssistantTextField(
                                    text: $email,
                                    isSecure: .constant(false),
                                    placeholder: "Enter Email",
                                    fieldType: .Email,
                                    returnKeyType: .next,
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                        }
                        Button(action: forgotTapped) {
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
                                    Text("Send Reset Link")
                                        .font(AppFont.manropeMedium(16))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .allowsHitTesting(!isUploading)
                        .opacity(isUploading ? 0.7 : 1)
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back to Login")
                            }
                            .font(AppFont.manropeMedium(16))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .frame(height: 360)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
        .navigationDestination(isPresented: $goToVerifyOTP) {
            ForgotOTPView(email: email,goToVerifyOTP:$goToVerifyOTP,goToForgotView:$goToForgotView)
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
    }
    // MARK: - Forgot API
    func forgotTapped() {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.emailEmpty)
            return
        }
        if !isValidEmail(email) {
            validator.showValidation(ValidationMessages.emailInvalid)
            return
        }
        let param: [String: Any] = [
            "email": email
        ]
        isUploading = true
        FORGOT.ForgotAPI(param: param) { response in
            guard let response else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
                return
            }
            validator.showValidation(response.message ?? "")
            validator.showToast = true
            if response.success == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    goToVerifyOTP = true
                    isUploading = false
                }
            }else {
                isUploading = false
            }
        }
    }
}
