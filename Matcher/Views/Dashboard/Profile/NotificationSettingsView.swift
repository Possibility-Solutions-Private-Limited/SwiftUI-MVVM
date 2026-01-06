import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var allNotifications = true
    @State private var chatAlerts = true
    @State private var likesNotifications = true
    @State private var messageNotifications = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.splashTop, .splashBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 16) {
                headerView
                ScrollView {
                    VStack(spacing: 0) {
                        sectionHeader("All Notifications")
                        toggleRow(
                            title: "Turn On All Notifications",
                            isOn: $allNotifications
                        )
                        sectionHeader("Chat Notifications")
                        toggleRow(
                            title: "Turn On Chat Alerts",
                            isOn: $chatAlerts
                        )
                        sectionHeader("Likes Notifications")
                        toggleRow(
                            title: "Get Notified When Someone Likes Your Post",
                            isOn: $likesNotifications
                        )
                        sectionHeader("Message Notifications")
                        toggleRow(
                            title: "Receive Alerts For New Messages",
                            isOn: $messageNotifications
                        )
                    }
                }
            }
            .padding(.top, 20)
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
                Text("Notification Settings").font(AppFont.manropeSemiBold(16))
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.manropeMedium(13))
                .foregroundColor(AppColors.Black.opacity(0.7))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(AppColors.ExtralightGray.opacity(0.6))
    }
    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(AppFont.manropeSemiBold(15))
                .foregroundColor(AppColors.Black)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(
                    SwitchToggleStyle(tint: AppColors.primaryYellow)
                )
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(AppColors.lightGray)
    }
}
