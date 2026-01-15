import SwiftUI

struct LikeView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var interaction = InteractionModel()
    @State private var showNotifications = false
    @State private var selectedUser: InteractedUser? = nil
    private let spacing: CGFloat = 14
    private let horizontalPad: CGFloat = 15
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = (geo.size.width - (horizontalPad * 2) - spacing) / 2
                ZStack {
                    LinearGradient(
                        colors: [.splashTop, .splashBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    VStack(spacing: 20) {
                        header
                        if interaction.InteractedUser.isEmpty {
                            NoRoomsView()
                        } else {
                            ScrollView(showsIndicators: false) {
                                LazyVGrid(
                                    columns: [
                                        GridItem(.fixed(width), spacing: spacing),
                                        GridItem(.fixed(width), spacing: spacing)
                                    ],
                                    spacing: 15
                                ) {
                                    ForEach(interaction.InteractedUser) { user in
                                        ProfileCardView(user: user, width: width) {
                                            selectedUser = user
                                        }
                                        .onAppear {
                                            if user.id == interaction.InteractedUser.last?.id {
                                                interaction.loadMore()
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 50)
                            }
                            .toolbar(.hidden, for: .tabBar)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedUser) { data in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                ChatView(
                    senderId: currentUserId,
                    chatId: data.user?.chatting?.id ?? 0,
                    receiverId: data.user?.id ?? 0,
                    UserImg: data.user?.photos?.first?.file ?? "",
                    userName: data.user?.first_name ?? ""
                ).environmentObject(interaction)
            }
        }
        .onAppear {
            interaction.fetchInteraction()
        }
    }
    private var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    case .failure:
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    default:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                if let savedAddress = KeychainHelper.shared.get(forKey: "address") {
                    Text(savedAddress)
                        .font(AppFont.manropeSemiBold(16))
                }
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
}
struct NoRoomsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("likiy")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text("No Matches Nearby")
                .font(AppFont.manropeBold(18))
                .foregroundColor(.black)
            Text("Try changing your location or preferences")
                .font(AppFont.manrope(12))
                .foregroundColor(.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .tabBar)
    }
}
struct ProfileCardView: View {
    let user: InteractedUser
    let width: CGFloat
    let onChatTap: () -> Void
    @StateObject private var loader = ImageLoader()
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            let photoURL = user.user?.photos?.first?.file
            Group {
                if let uiImage = loader.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let url = photoURL, !url.isEmpty {
                    Color.clear
                        .onAppear { loader.load(from: url) }
                    ProgressView()
                } else {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: width, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4))
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(user.user?.first_name ?? "") \(user.user?.last_name ?? "") 🌼")
                        .font(AppFont.manropeSemiBold(14))
                        .foregroundColor(.white)
                    Text(" \(calculateAge(user.user?.dob ?? ""))")
                        .font(AppFont.manropeExtraBold(16))
                        .foregroundColor(.white)
                }
                Text(user.user?.profile?.professional_field_data?.title ?? "")
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(.white.opacity(0.9))
                HStack {
                    Text(user.user?.profile?.work_shift ?? "Day Shift")
                        .font(AppFont.manropeMedium(11))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onChatTap) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.primaryYellow)
                        )
                    }
                }
            }
            .padding(15)
        }
        .background(AppColors.backgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppColors.Black.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}
