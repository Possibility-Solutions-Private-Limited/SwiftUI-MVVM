import SwiftUI

struct ChatListView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var chatModel = ChatsModel()
    @State private var selectedChat: Chat?
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
                    if chatModel.chats.isEmpty {
                        NoChatView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(chatModel.chats, id: \.id) { chat in
                                    Button {
                                        selectedChat = chat
                                    } label: {
                                        VStack(spacing: 0) {
                                            ChatRowView(chat: chat)
                                                .environmentObject(chatModel)
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
                                }
                            }
                            .padding(.bottom, 68)
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .toolbar(.hidden, for: .tabBar)
            }
            .onAppear {
                chatModel.fetchChats()
            }
            .navigationDestination(item: $selectedChat) { chat in
                let loginUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                let isCurrent = chat.senderDetail.id == loginUserId
                let receiver = isCurrent ? chat.receiverDetail : chat.senderDetail
                ChatView(
                    senderId: loginUserId,
                    chatId: chat.id,
                    receiverId: receiver.id ?? 0,
                    UserImg: receiver.photos?.first?.file ?? "",
                    userName: receiver.firstName ?? "",
                    chat: chat
                )
                .environmentObject(chatModel)
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
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
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
    struct NoChatView: View {
        var body: some View {
            VStack(spacing: 0) {
                Image("no_chat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("No Conversations Yet")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(.black)
                Text("Start the conversation and make a connection")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .tabBar)
        }
    }
    struct ChatRowView: View {
        @ObservedObject var chat: Chat
        @EnvironmentObject var chatVM: ChatsModel
        let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
        var isCurrentUserSender: Bool {
            chat.senderDetail.id == currentUserId
        }
        var userDetail: User? {
            isCurrentUserSender ? chat.receiverDetail : chat.senderDetail
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
                    if let lastMessage = chat.lastMessage {
                        switch lastMessage.type {
                        case "file":
                            let filePath = chat.lastMessage?.file ?? ""
                            let ext = filePath.lowercased()
                            if ext.hasSuffix(".jpg") || ext.hasSuffix(".jpeg") || ext.hasSuffix(".png") {
                                HStack(spacing: 4) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 13))
                                    Text("File")
                                        .font(AppFont.manrope(14))
                                } .foregroundColor(.black.opacity(0.6))
                            } else if ext.hasSuffix(".m4a") || ext.hasSuffix(".mp3") || ext.hasSuffix(".wav") {
                                HStack(spacing: 4) {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 13))
                                    Text("Voice message")
                                        .font(AppFont.manrope(14))
                                }
                                .foregroundColor(.black.opacity(0.6))
                            }
                        case "audio":
                            HStack(spacing: 4) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 13))
                                Text("Voice message")
                                    .font(AppFont.manrope(14))
                            }
                            .foregroundColor(.black.opacity(0.6))
                        default:
                            Text(lastMessage.message ?? "Say Hi 👋")
                                .font(AppFont.manrope(14))
                                .foregroundColor(.black.opacity(0.6))
                                .lineLimit(1)
                        }
                    } else {
                        Text("Say Hi 👋")
                            .font(AppFont.manrope(14))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(formattedTimeFromCreatedAt(chat.createdAt))
                        .font(AppFont.manrope(12))
                        .foregroundColor(.black.opacity(0.5))
                    if (chat.unseen_message_count ?? 0) > 0 {
                        Text("\(chat.unseen_message_count ?? 0)")
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
}
