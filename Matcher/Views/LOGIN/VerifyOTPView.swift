import SwiftUI

struct VerifyOTPView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var validator = ValidationHelper()
    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var timerCount = 30
    @State private var isResendActive = false
    @State private var message = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phone: String
    @StateObject private var SIGNUP = SignUpModel()
    @StateObject private var VERIFY = VerifyModel()
    @State private var goToYourself = false
    @State private var isUploading = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image("backline")
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Image("locker")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding()
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("Verify OTP")
                        .font(AppFont.manropeBold(22))

                    Text("We’ve sent a 6-digit verification code to your email address. Please enter it below to continue.")
                        .font(AppFont.manrope(13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(email)
                        .font(AppFont.manropeSemiBold(14))
                        .padding(.top, 6)

                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { i in
                            otpBox(index: i)
                        }
                    }
                    .padding(.top, 30)
                }
                .padding()
            }
        }.safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if isResendActive {
                        Button {
                            resendOTP()
                        } label: {
                            if isUploading {
                                ProgressView()
                                    .frame(height: 20)
                        } else {
                            Text("Send again")
                                    .font(AppFont.manrope(14))
                        }
                    }
                    .disabled(isUploading)
                } else {
                Text("Send again in \(timerCount) secs")
                            .font(AppFont.manrope(14))
                            .foregroundColor(.gray)
                }
                Button(action: submitOTP) {
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
                            Text("Verify OTP")
                                .font(AppFont.manropeMedium(16))
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .allowsHitTesting(!isUploading)
                .opacity(isUploading ? 0.7 : 1)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.white)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationDestination(isPresented: $goToYourself) {
            YourselfView()
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
        .padding()
        .onAppear { focusedField = 0 }
        .onReceive(timer) { _ in
            if timerCount > 0 { timerCount -= 1 } else { isResendActive = true }
        }
    }
    @ViewBuilder
    func otpBox(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(focusedField == index ? Color.blue : Color.gray, lineWidth: 2)
                .frame(width: 50, height: 55)
            TextField("", text: Binding(
                get: { otp[index] },
                set: { value in
                    handleInput(value, index)
                })
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 22, weight: .medium))
            .focused($focusedField, equals: index)
            .onChange(of: otp[index]) { oldValue, newValue in
                if newValue.isEmpty {
                    if index > 0 { focusedField = index - 1 }
                } else {
                    if index < 5 { focusedField = index + 1 } else { focusedField = nil }
                }
                if newValue.count > 1 {
                    for (i, char) in newValue.prefix(6).enumerated() {
                        otp[i] = String(char)
                    }
                    focusedField = min(newValue.count, 5)
                }
            }
            .onTapGesture {
                focusedField = index
            }
        }
    }
    func handleInput(_ value: String, _ index: Int) {
        let filtered = value.filter { $0.isNumber }
        otp[index] = filtered
    }
    func submitOTP() {
        let finalOTP = otp.joined()
        guard finalOTP.count == 6 else {
            message = "Please enter all 6 digits"
            return
        }
        isUploading = true
        verifyOTP(finalOTP)
    }
    func verifyOTP(_ otp: String) {
        let param: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password,
            "mobile": phone,
            "otp": otp,
            "device_token": KeychainHelper.shared.get(forKey: "device_token") ?? "",
            "device_type": "ios"
        ]
        VERIFY.VerifyAPI(param: param) { response in
            if let response = response {
                if response.success {
                    let data = response.data
                    KeychainHelper.shared.save(response.token ?? "", forKey: "access_token")
                    KeychainHelper.shared.save(data?.first_name ?? "", forKey: "first_name")
                    KeychainHelper.shared.save(data?.email ?? "", forKey: "email")
                    KeychainHelper.shared.save(data?.mobile ?? "", forKey: "mobile")
                    KeychainHelper.shared.save(data?.gender ?? "", forKey: "gender")
                    validator.showValidation(response.message ?? "")
                    validator.showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        goToYourself = true
                        isUploading = false
                    }
                } else {
                    validator.showValidation(response.message ?? "")
                    validator.showToast = true
                    isUploading = false
                }
            } else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
            }
        }
    }
    func resendOTP() {
        isUploading = true
        let param: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password,
            "mobile": phone,
            "device_token": KeychainHelper.shared.get(forKey: "device_token") ?? "",
            "device_type": "ios"
        ]
        SIGNUP.SignUpAPI(param: param) { response in
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
                    otp = Array(repeating: "", count: 6)
                    timerCount = 30
                    isResendActive = false
                    isUploading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        focusedField = 0
                    }
                }
            } else {
                isUploading = false
            }
        }
    }
}
