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
                        if !chatModel.chats.isEmpty {
                            Section {
                                ForEach(chatModel.chats, id: \.id) { chat in
                                    Button {
                                        selectedChat = chat
                                    } label: {
                                        VStack(spacing: 0) {
                                            ChatRowView(chats: chat)
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 0.8)
                                                .padding(.leading, 20)
                                        }
                                        .contentShape(Rectangle())
                                        .background(
                                            selectedChat?.id == chat.id
                                            ? Color.gray.opacity(0.15)
                                            : Color.clear
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(.init())
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listSectionSeparator(.hidden)
                        }
                        if !chatModel.users.isEmpty {
                            Section {
                                ForEach(chatModel.users, id: \.id) { user in
                                    Button {
                                        selectedUser = user
                                    } label: {
                                        VStack(spacing: 0) {
                                            UserRowView(users: user)
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 0.8)
                                                .padding(.leading, 20)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(.init())
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listSectionSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                }
                .padding(.bottom, 68)
                .ignoresSafeArea(.container, edges: .bottom)
                .toolbar(.hidden, for: .tabBar)
            }
            .onAppear {
                chatModel.fetchChat()
            }
            .navigationDestination(item: $selectedChat) { chat in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                let isSender = chat.senderDetail.id == currentUserId
                let sender = isSender ? chat.receiverDetail : chat.senderDetail
                let receiver = isSender ? chat.senderDetail : chat.receiverDetail
                ChatView(
                    senderId: sender.id ?? 0,
                    chatId: chat.id,
                    receiverId: receiver.id ?? 0,
                    UserImg: "",
                    userName: sender.firstName ?? ""
                )
            }
            .navigationDestination(item: $selectedUser) { user in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                ChatView(
                    senderId: currentUserId,
                    chatId: 0,
                    receiverId: user.id ?? 0,
                    UserImg: user.photos?.first?.file ?? "",
                    userName: user.firstName ?? ""
                )
            }
        }
    }
    private var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3)
                            )
                    } else if phase.error != nil {
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
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
                    Text(savedAddress).font(AppFont.manropeSemiBold(16))
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
struct ChatRowView: View {
    let chats: Chat
    let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
    var isCurrentUserSender: Bool {
        chats.senderDetail.id == currentUserId
    }
    var userDetail: User? {
        isCurrentUserSender ? chats.receiverDetail : chats.senderDetail
    }
    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                if let imageURL = userDetail?.photos?.first?.file,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                 }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(userDetail?.firstName ?? "")
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(.black)
                Text(chats.lastMessage?.message ?? "Say Hi 👋")
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
            if let imageURL = users.photos?.first?.file,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            }
            Text(users.firstName ?? "")
                .font(AppFont.manropeSemiBold(16))
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}
