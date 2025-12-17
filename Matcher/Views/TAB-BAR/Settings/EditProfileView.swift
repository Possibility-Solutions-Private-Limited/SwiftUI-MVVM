import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userAuth: UserAuth

    @State var firstName: String
    @State var email: String
    @State var mobile: String
    @State var gender: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Mobile", text: $mobile)
                        .keyboardType(.phonePad)
                    TextField("Gender", text: $gender)
                }

                Section {
                    Button(action: {
                        // Update UserAuth
                        userAuth.firstName = firstName
                        userAuth.email = email
                        userAuth.mobile = mobile
                        userAuth.gender = gender

                        // Save to Keychain
                        KeychainHelper.shared.save(firstName, forKey: "first_name")
                        KeychainHelper.shared.save(email, forKey: "email")
                        KeychainHelper.shared.save(mobile, forKey: "mobile")
                        KeychainHelper.shared.save(gender, forKey: "gender")

                        // Dismiss sheet
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
