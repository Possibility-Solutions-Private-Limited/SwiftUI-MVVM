//
//  ChatListView.swift
//  Matcher
//
//  Created by POSSIBILITY on 18/12/25.
//
import SwiftUI

struct ChatListView: View {
    @StateObject var ChatModel = ChatsModel()
    @State private var selectedChat: Chat?
    @State private var selectedUser: Users?
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Active Users
                Section(header: Text("Active Users")) {
                    ForEach(ChatModel.chats, id: \.id) { chat in
                        Button {
                            selectedChat = chat
                        } label: {
                            ChatRowView(chats: chat)
                        }
                    }
                }
                // MARK: - Near by Users
                Section(header: Text("Near by Users")) {
                    ForEach(ChatModel.users, id: \.id) { user in
                        Button {
                            selectedUser = user
                        } label: {
                            UserRowView(users: user)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Chats")
            .onAppear {
//                ChatModel.fetchChat()
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
                    UserImg:"",
                    userName:senderDetail?.first_name ?? ""
                )
            }
            .navigationDestination(item: $selectedUser) { user in
                let currentUserId = KeychainHelper.shared.getInt(forKey: "userId") ?? 0
                ChatView(
                    senderId: currentUserId,
                    chatId: 0,
                    receiverId: user.id ?? 0,
                    UserImg: user.image ?? "",
                    userName:user.first_name ?? ""
                )
            }
        }
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
                    Text(userDetail?.first_name ?? "")
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
struct UserRowView: View {
    let users: Users
    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = users.image,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(users.first_name ?? "")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
