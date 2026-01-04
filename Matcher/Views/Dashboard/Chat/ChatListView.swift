import SwiftUI

struct ChatListView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @StateObject var chatModel = ChatsModel()
    @State private var selectedChat: Chat?
    @State private var selectedUser: Users?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.splashTop, .splashBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    List {
                        // MARK: Active Chats
                        if !chatModel.chats.isEmpty {
                            Section {
                                ForEach(chatModel.chats, id: \.id) { chat in
                                    Button {
                                        selectedChat = chat
                                    } label: {
                                        VStack(spacing: 0) {
                                            ChatRowView(chats: chat)

                                            Divider()
                                                .padding(.leading, 80)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }

                        // MARK: Nearby Users
                        if !chatModel.users.isEmpty {
                            Section {
                                ForEach(chatModel.users, id: \.id) { user in
                                    Button {
                                        selectedUser = user
                                    } label: {
                                        VStack(spacing: 0) {
                                            UserRowView(users: user)

                                            Divider()
                                                .padding(.leading, 80)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                chatModel.fetchChat()
            }
            .navigationDestination(item: $selectedChat) { chat in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                let isSender = chat.senderID == currentUserId
                let sender = isSender ? chat.receiverDetail : chat.senderDetail
                let receiver = isSender ? chat.senderDetail : chat.receiverDetail

                ChatView(
                    senderId: sender?.id ?? 0,
                    chatId: chat.id,
                    receiverId: receiver?.id ?? 0,
                    UserImg: "",
                    userName: sender?.firstName ?? ""
                )
            }
            .navigationDestination(item: $selectedUser) { user in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0

                ChatView(
                    senderId: currentUserId,
                    chatId: 0,
                    receiverId: user.id ?? 0,
                    UserImg: user.image ?? "",
                    userName: user.first_name ?? ""
                )
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))

            Spacer()

            HStack(spacing: 6) {
                Image("location")
                Text(KeychainHelper.shared.get(forKey: "address") ?? "")
                    .font(AppFont.manropeSemiBold(16))
            }

            Spacer()

            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
        }
        .padding()
    }
}
struct ChatRowView: View {
    let chats: Chat
    let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0

    var isCurrentUserSender: Bool {
        chats.senderID == currentUserId
    }

    var userDetail: User? {
        isCurrentUserSender ? chats.receiverDetail : chats.senderDetail
    }

    var body: some View {
        HStack(spacing: 14) {

            // Avatar + online dot
            ZStack(alignment: .bottomTrailing) {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))

                Circle()
                    .fill(Color.yellow)
                    .frame(width: 10, height: 10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(userDetail?.firstName ?? "")
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(.black)

                Text(chats.last?.message ?? "Say Hi 👋")
                    .font(AppFont.manrope(14))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("05:00 PM")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))

                if (chats.unseen_message_count ?? 0) > 0 {
                    Text("\(chats.unseen_message_count ?? 0)")
                        .font(AppFont.manropeSemiBold(12))
                        .frame(width: 22, height: 22)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}
struct UserRowView: View {
    let users: Users

    var body: some View {
        HStack(spacing: 14) {

            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))

            Text(users.first_name ?? "")
                .font(AppFont.manropeSemiBold(16))
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}
