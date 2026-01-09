import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var userAuth: UserAuth
    @State private var showDeleteSheet = false
    @StateObject private var DELETE = deleteAccountModel()
    @State private var showLogoutSheet = false
    @StateObject private var LOGOUT = LogoutModel()
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.splashTop, .splashBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack(spacing: 16) {
                    headerView
                    profileCard
                    additionalSettings
                    Spacer()
                    deleteAccountButton
                }
                .padding(.horizontal)
                .padding(.top, 20)
                if showDeleteSheet {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDeleteSheet = false
                        }
                }
                ZStack {
                    if showDeleteSheet {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showDeleteSheet = false
                                }
                            }
                            .transition(.opacity)
                            .zIndex(5)
                    }
                    if showDeleteSheet {
                        DeleteAccountSheetView(
                            isPresented: $showDeleteSheet,
                            onDelete: {
                                DELETE.deleteAccount() { response in
                                    if let response = response {
                                        if response.success {
                                            DispatchQueue.main.async {
                                                dismiss()
                                                router.isTabBarHidden = false
                                                userAuth.logout()
                                                router.reset()
                                             }
                                         }
                                     }
                                 }
                             }
                         )
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                        .zIndex(10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDeleteSheet)
                    }
                }
                if showLogoutSheet {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showLogoutSheet = false
                        }
                }
                ZStack {
                    if showLogoutSheet {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showLogoutSheet = false
                                }
                            }
                            .transition(.opacity)
                            .zIndex(5)
                    }
                    if showLogoutSheet {
                        LogoutSheetView(
                            isPresented: $showLogoutSheet,
                            onDelete: {
                                LOGOUT.LogoutAPI() { response in
                                    if let response = response {
                                        if response.success {
                                            DispatchQueue.main.async {
                                                dismiss()
                                                router.isTabBarHidden = false
                                                userAuth.logout()
                                                router.reset()
                                             }
                                         }
                                     }
                                 }
                             }
                         )
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                        .zIndex(10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showLogoutSheet)
                    }
                }
            }
            .animation(.easeInOut, value: showDeleteSheet)
            .animation(.easeInOut, value: showLogoutSheet)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            router.isTabBarHidden = true
        }
    }
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
                router.isTabBarHidden = false
            } label: {
                Circle()
                    .fill(AppColors.primaryYellow)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .overlay(
                        Image(systemName: "arrow.left")
                            .foregroundColor(AppColors.Black)
                    )
            }
            Spacer()
            HStack(spacing: 5) {
                Text("Setting").font(AppFont.manropeSemiBold(16))
            }
            Spacer()
            Spacer()
        }
    }
    private var profileCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: userAuth.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if phase.error != nil {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        ProgressView()
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(userAuth.firstName)
                        .font(AppFont.manropeSemiBold(16))
                        .foregroundColor(AppColors.Black)
                    Text(userAuth.email)
                        .font(AppFont.manrope(13))
                        .foregroundColor(AppColors.Gray)
                }
                Spacer()
            }
            Divider()
                .background(AppColors.borderGray)
            Button {
                showLogoutSheet = true
            } label: {
                HStack {
                    Text("Log out")
                        .font(AppFont.manropeMedium(14))
                        .foregroundColor(.orange)
                    Image("logout")
                 }
             }
         }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundWhite.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
        )
    }
    private var additionalSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Settings")
                .font(AppFont.manropeSemiBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top,20)
             VStack(spacing: 0) {
                settingsRow(icon: "notify", title: "Notification Settings")
                divider
                settingsRow(icon: "helps", title: "Help And Supports")
                divider
                settingsRow(icon: "faq", title: "FAQs")
                divider
                settingsRow(icon: "privacy", title: "Privacy Policy")
                divider
                settingsRow(icon: "terms", title: "Terms And Conditions")
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.backgroundWhite.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
    private func settingsRow(icon: String, title: String) -> some View {
        NavigationLink(destination: destinationView(for: title)) {
            HStack(spacing: 12) {
                Image(icon)
                Text(title)
                    .font(AppFont.manropeMedium(15))
                    .foregroundColor(AppColors.Black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.Black)
            }
            .padding()
        }
    }
    @ViewBuilder
    private func destinationView(for title: String) -> some View {
        switch title {
        case "Notification Settings":
            NotificationSettingsView()
        case "Help And Supports":
            HelpSupportView()
        case "FAQs":
            FAQView()
        case "Privacy Policy":
            PrivacyPolicyView()
        case "Terms And Conditions":
            TermsView()
        default:
            EmptyView()
        }
    }
    private var divider: some View {
        Divider()
            .background(AppColors.borderGray)
            .padding(.leading, 48)
    }
    private var deleteAccountButton: some View {
        ZStack {
            Button {
                showDeleteSheet = true
            } label: {
                HStack {
                    Text("Delete Account")
                        .font(AppFont.manropeSemiBold(16))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Image(systemName: "chevron.right")
                }
                .foregroundColor(AppColors.backgroundWhite)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.Black)
                )
            }
            .padding(.bottom, 10)
        }
    }
}


            
