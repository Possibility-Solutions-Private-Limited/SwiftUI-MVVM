import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject var ChatModel = ChatsModel()
    @State private var selectedChat: Chat?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [.splashTop, .splashBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    header
                    ZStack {
                        if ChatModel.chats.isEmpty {
                            NoChatsView()
                        }else{
                            List {
                                Section(header: Text("Active Chats")) {
                                    ForEach(ChatModel.chats, id: \.id) { chat in
                                        Button {
                                            selectedChat = chat
                                        } label: {
                                            ChatRowView(chats: chat)
                                        }
                                    }
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                         }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 5)
                }
            }
        }
        .onAppear {
            ChatModel.fetchChat()
        }
        .navigationDestination(item: $selectedChat) { chat in
            let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
            let isCurrentUserSender = chat.senderID == currentUserId
            let senderDetail = isCurrentUserSender ? chat.receiverDetail : chat.senderDetail
            let receiverDetail = isCurrentUserSender ? chat.senderDetail : chat.receiverDetail
            
            ChatView(
                senderId: senderDetail?.id ?? 0,
                chatId: chat.id,
                receiverId: receiverDetail?.id ?? 0,
                UserImg: "",
                userName: senderDetail?.firstName ?? ""
            )
        }
    }
    struct NoChatsView: View {
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
            Image("bell")
        }
        .padding(.horizontal)
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
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(userDetail?.firstName ?? "")
                        .font(.headline)
                        .foregroundColor(.black)

                    HStack(spacing: 2) {
                        HStack(spacing: -4) {
                            Image(systemName: "checkmark")
                                .font(.caption2)
                                .foregroundColor(chats.last?.isSeen == "1" ? .blue : .gray)
                            Image(systemName: "checkmark")
                                .font(.caption2)
                                .foregroundColor(chats.last?.isSeen == "1" ? .blue : .gray)
                        }

                        if let message = chats.last?.message, !message.isEmpty {
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        } else {
                            HStack(spacing: 2) {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.gray)
                                Text("File")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 6)

            if (chats.unseen_message_count ?? 0) > 0 {
                Text("\(chats.unseen_message_count ?? 0)")
                    .font(.caption2)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .offset(x: -10, y: 20)
            }
        }
    }
}
