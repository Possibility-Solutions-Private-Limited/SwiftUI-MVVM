import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @StateObject private var privacyVM = PrivacyModel()
    @State private var webHeight: CGFloat = 1
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
                    if !privacyVM.privacyHTML.isEmpty {
                        HTMLWebView(
                            htmlString: privacyVM.privacyHTML,
                            dynamicHeight: $webHeight
                        )
                        .frame(height: webHeight)
                        .padding(.horizontal)
                    } else {
                        ProgressView()
                            .padding(.top, 40)
                    }
                }
            }
            .padding(.top, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            router.isTabBarHidden = true
            privacyVM.fetchPrivacy()
        }
    }
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
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
            Text("Privacy Policy")
                .font(AppFont.manropeSemiBold(16))
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
