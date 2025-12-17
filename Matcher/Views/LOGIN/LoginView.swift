import SwiftUI

struct LoginView: View {
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var rememberMe = false
    @State private var isSecure = true
    @State private var isSignUpSecure = true
    @State private var scrollToTop = UUID()
    @StateObject private var validator = ValidationHelper()
    @State private var goToVerifyOTP = false
    @StateObject private var LOGIN = LoginModel()
    @StateObject private var SIGNUP = SignUpModel()
    @EnvironmentObject var userAuth: UserAuth
    enum FormField: Hashable {
        case loginEmail, loginPassword
        case signUpFirstName, signUpLastName, signUpEmail, signUpPhone, signUpPassword
    }
    @FocusState private var focusedField: FormField?
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
                                .frame(height: 400)
                                .clipped()
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                                )
                                .ignoresSafeArea(edges: .top)
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 220)
                            VStack(alignment: .leading, spacing: 20) {
                                Text(selectedTab == 0 ? "Log in" : "Sign Up")
                                    .font(AppFont.manropeSemiBold(20))
                                    .padding(.top, 20)
                                    .padding(.leading, 20)
                                Text(selectedTab == 0 ?
                                     "Please enter your email and password to log in." :
                                        "Create an account by filling the details below.")
                                .foregroundColor(.gray)
                                .font(AppFont.manrope(14))
                                HStack(spacing: 0) {
                                    Button { selectedTab = 0 } label: {
                                        Text("Log in")
                                            .frame(maxWidth: .infinity)
                                            .font(AppFont.manropeMedium(14))
                                            .padding()
                                            .background(selectedTab == 0 ? AppColors.primaryYellow : Color.clear)
                                            .foregroundColor(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                    Button { selectedTab = 1 } label: {
                                        Text("Sign up")
                                            .frame(maxWidth: .infinity)
                                            .font(AppFont.manropeMedium(14))
                                            .padding()
                                            .background(selectedTab == 1 ? AppColors.primaryYellow : Color.clear)
                                            .foregroundColor(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                }
                                .padding(5)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.yellow.opacity(0.08))
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray,lineWidth: 1))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                if selectedTab == 0 { loginForm(proxy: proxy) }
                                else { signUpForm(proxy: proxy) }
                                HStack {
                                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.4))
                                    Text("OR").font(AppFont.manrope(16))
                                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.4))
                                }
                                .padding(.vertical, 20)
                                HStack(spacing: 0) {
                                    Button(action: {}) {
                                        Image("google_icon").resizable().frame(width: 50, height: 50).padding(10)
                                    }
                                    Button(action: {}) {
                                        Image("apple_logo").resizable().frame(width: 50, height: 50).padding(10)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 20)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 8)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                            .offset(y: -70)
                            .id(scrollToTop)
                        }
                    }
                    .onChange(of: focusedField) { _, newField in
                        withAnimation {
                            if let field = newField {
                                proxy.scrollTo(field, anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $goToVerifyOTP) {
                VerifyOTPView(firstName: firstName, lastName: lastName, email: email, password: password, phone: phone)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
        .ignoresSafeArea()
    }
    func loginForm(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Email").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("mail")
                    NoAssistantTextField(
                        text: $email,
                        isSecure: .constant(false),
                        placeholder: "Enter Email",
                        fieldType:.Email,
                        returnKeyType: .next,
                        onCommit: { focusedField = .loginPassword }
                    )
                    .focused($focusedField, equals: .loginEmail)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            VStack(alignment: .leading) {
                Text("Password").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("lock")
                    NoAssistantTextField(
                        text: $password,
                        isSecure: $isSecure,
                        placeholder: "Enter Password",
                        fieldType: .Password,
                        returnKeyType: .done,
                        onCommit: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .loginPassword)
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            HStack {
                Button { rememberMe.toggle() } label: {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(rememberMe ? Color.clear : AppColors.primaryYellow, lineWidth: 1)
                                .background(rememberMe ? AppColors.primaryYellow : Color.clear)
                                .frame(width: 18, height: 18)
                            if rememberMe {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        Text("Remember me").foregroundColor(AppColors.textGray).font(AppFont.manrope(14))
                    }
                }
                Spacer()
                NavigationLink(destination: ForgotView()) {
                    Text("Forgot Password?").foregroundColor(AppColors.textGray).font(AppFont.manrope(14))
                }
            }
            Button(action: { logIn() }) {
                if isUploading {
                    ProgressView()
                        .frame(width:260, height:50)
                } else {
                    Text("Log in")
                        .frame(maxWidth: .infinity)
                        .font(AppFont.manropeMedium(16))
                        .padding()
                        .background(AppColors.primaryYellow)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
            }
            .padding(.top, 10)
            .disabled(isUploading)
        }
        .padding(.horizontal)
    }
    func signUpForm(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("First Name").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("user")
                    NoAssistantTextField(
                        text: $firstName,
                        isSecure: .constant(false),
                        placeholder: "Enter First Name",
                        fieldType: .Normal,
                        returnKeyType: .next,
                        onCommit: { focusedField = .signUpLastName }
                    )
                    .focused($focusedField, equals: .signUpFirstName)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            VStack(alignment: .leading) {
                Text("Last Name").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("user")
                    NoAssistantTextField(
                        text: $lastName,
                        isSecure: .constant(false),
                        placeholder: "Enter Last Name",
                        fieldType: .Normal,
                        returnKeyType: .next,
                        onCommit: { focusedField = .signUpEmail }
                    )
                    .focused($focusedField, equals: .signUpLastName)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            VStack(alignment: .leading) {
                Text("Email").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("mail")
                    NoAssistantTextField(
                        text: $email,
                        isSecure: .constant(false),
                        placeholder: "Enter Email",
                        fieldType:.Email,
                        returnKeyType: .next,
                        onCommit: { focusedField = .signUpPhone }
                    )
                    .focused($focusedField, equals: .signUpEmail)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            VStack(alignment: .leading) {
                Text("Mobile").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("phone")
                    PhoneTextField(
                        text: $phone,
                        onNext: { focusedField = .signUpPassword },
                        onCancel: { focusedField = nil }
                    )
                    .frame(height: 22)
                    .focused($focusedField, equals: .signUpPhone)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            VStack(alignment: .leading) {
                Text("Password").font(AppFont.manropeSemiBold(13))
                HStack {
                    Image("lock")
                    NoAssistantTextField(
                        text: $password,
                        isSecure: $isSignUpSecure,
                        placeholder: "Enter Password",
                        fieldType: .Password,
                        returnKeyType: .done,
                        onCommit: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .signUpPassword)
                    Button {
                        isSignUpSecure.toggle()
                    } label: {
                        Image(systemName: isSignUpSecure ? "eye" : "eye.slash")
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            Button(action: { signUp() }) {
                if isUploading {
                    ProgressView()
                        .frame(width:260, height:50)
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .font(AppFont.manropeMedium(16))
                        .padding()
                        .background(AppColors.primaryYellow)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
            }
            .padding(.top, 10)
            .disabled(isUploading)
        }
        .padding(.horizontal)
    }
    func logIn() {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validator.showValidation(ValidationMessages.emailEmpty)
                return
        }
        if !isValidEmail(email) {
                validator.showValidation(ValidationMessages.emailInvalid)
                return
        }
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validator.showValidation(ValidationMessages.passwordEmpty)
                return
        }
        if password.count < 6 {
                validator.showValidation(ValidationMessages.passwordTooShort)
                return
        }
        isUploading = true
        let param: [String: Any] = [
            "email": email,
            "password": password,
            "device_token": KeychainHelper.shared.get(forKey: "device_token") ?? ""
        ]
        LOGIN.LoginAPI(param: param) { response in
            guard let response else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
                return
            }
            guard response.success == true else {
                validator.showValidation(response.message ?? "")
                validator.showToast = true
                isUploading = false
                return
            }
            let data = response.data
            isUploading = false
            KeychainHelper.shared.save(response.token ?? "", forKey: "access_token")
            KeychainHelper.shared.save(data?.first_name ?? "", forKey: "first_name")
            KeychainHelper.shared.save(data?.email ?? "", forKey: "email")
            KeychainHelper.shared.save(data?.mobile ?? "", forKey: "mobile")
            KeychainHelper.shared.save(data?.gender ?? "", forKey: "gender")
            userAuth.firstName = data?.first_name ?? ""
            userAuth.email = data?.email ?? ""
            userAuth.mobile = data?.mobile ?? ""
            userAuth.gender = data?.gender ?? ""
            userAuth.login(email: email, password: password)
        }
    }
    func signUp() {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.firstNameEmpty)
            return
        }
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.lastNameEmpty)
            return
        }
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.emailEmpty)
            return
        }
        if !isValidEmail(email) {
            validator.showValidation(ValidationMessages.emailInvalid)
            return
        }
        if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.phoneEmpty)
            return
        }
        if phone.count < 10 {
            validator.showValidation(ValidationMessages.phoneInvalid)
            return
        }
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validator.showValidation(ValidationMessages.passwordEmpty)
            return
        }
        if password.count < 6 {
            validator.showValidation(ValidationMessages.passwordTooShort)
            return
        }
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
            if response.success == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isUploading = false
                    goToVerifyOTP = true
                }
            }
        }
    }
}
