import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("User Details")) {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: userAuth.image)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                            Spacer()
                        }
                        .padding(.vertical, 10)

                        Text("👤  \(userAuth.firstName)")
                        Text("✉️  \(userAuth.email)")
                        Text("📱  \(userAuth.mobile)")
                        Text("🧬  \(userAuth.gender)")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Profile")
                .navigationBarItems(trailing:
                    Button(action: {
                        showEditProfile = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                    }
                )

                Button(action: {
                    userAuth.logout()
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(
                firstName: userAuth.firstName,
                email: userAuth.email,
                mobile: userAuth.mobile,
                gender: userAuth.gender
            )
            .environmentObject(userAuth)
        }
    }
}
