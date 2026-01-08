import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @StateObject private var socketManager: SocketService
    @StateObject private var Chats = ChatHistoryModel()
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var showEmojiPicker = false
    @State private var selectedCategory = "Smileys"
    @State private var messageText = ""
    @State private var timer: Timer?
    @State private var isTyping = false
    @State private var typingTimer: Timer?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImagePickerView = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    let senderId: Int
    let chatId: Int
    let receiverId: Int
    let UserImg: String
    let userName: String
    var combinedMessages: [Message] {
        Chats.messages + socketManager.messages
    }
    init(senderId: Int, chatId: Int, receiverId: Int, UserImg: String, userName: String) {
        self.senderId = senderId
        self.chatId = chatId
        self.receiverId = receiverId
        self.UserImg = UserImg
        self.userName = userName
        _socketManager = StateObject(wrappedValue: SocketService(senderId: senderId, receiverId: receiverId, chatId: chatId))
    }
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.splashTop, .splashBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        let msg: [String: Any] = [
                            "userId": "\(senderId)\(receiverId)",
                            "sender_id": "\(senderId)",
                            "receiver_id": "\(receiverId)"
                        ]
                        socketManager.destroy(msg: msg)
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("blackColour"))
                            .font(.title2)
                    }
                    AsyncImage(url: URL(string: UserImg)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        if socketManager.isOtherUserTyping {
                            HStack {
                                Text(userName).font(.headline)
                                Text("is typing...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .transition(.opacity)
                        }else{
                            Text(userName).font(.headline)
                        }
                        OnlineStatusView(isOnline: socketManager.isOtherUserOnline)
                    }
                    Spacer()
                }
                .padding()
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(combinedMessages, id: \.id) { message in
                                ChatBubble(
                                    message: message,
                                    isCurrentUser: message.sentby == senderId,
                                    UserImg: UserImg,
                                    isSeen: message.isSeen
                                )
                                .id(message.id)
                            }
                        }
                    }
                    .onChange(of: combinedMessages.count) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            scrollToLast(scrollViewProxy: scrollViewProxy)
                        }
                    }
                    .onAppear {
                        Chats.fetchChatHistory(chatId: "\(chatId)")
                        scrollToLast(scrollViewProxy: scrollViewProxy)
                    }
                }
                ChatInputBar(
                    messageText: $messageText,
                    onSend: {
                        sendMessage()
                    },
                    onMicTap: {
                    },
                    onAttachmentTap: {
                        showImagePicker = true
                    }
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, keyboard.currentHeight == 0 ? 30 : keyboard.currentHeight)
                .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showEmojiPicker) {
            VStack(spacing: 10) {
                Text("Choose Emoji")
                    .font(.headline)
                    .padding(.top)
                Picker("Category", selection: $selectedCategory) {
                    Text("Smileys").tag("Smileys")
                    Text("Gestures").tag("Gestures")
                    Text("Hearts").tag("Hearts")
                    Text("Objects").tag("Objects")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                let emojisByCategory: [String: [String]] = [
                    "Smileys": ["😊", "😂", "😍", "🤣", "😎", "😁", "😢", "🥲", "😇", "🤓"],
                    "Gestures": ["👍", "👎", "👏", "🙌", "🙏", "🤝", "👊", "👌", "🤞", "✌️"],
                    "Hearts": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "💔", "💖", "💗"],
                    "Objects": ["🎉", "🎁", "💯", "📱", "📸", "🕹️", "🖊️", "⚽️", "🏆", "🎧"]
                ]
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 5) {
                    ForEach(emojisByCategory[selectedCategory] ?? [], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 30))
                            .onTapGesture {
                                messageText += emoji
                                showEmojiPicker = false
                            }
                    }
                }
                .padding()
                Spacer()
            }
            .padding(.bottom)
            .presentationDetents([.height(200)])
        }
        .actionSheet(isPresented: $showImagePicker) {
            ActionSheet(
                title: Text("Select Image"),
                buttons: [
                    .default(Text("Camera")) {
                        imageSource = .camera
                        showImagePickerView = true
                    },
                    .default(Text("Photo Library")) {
                        imageSource = .photoLibrary
                        showImagePickerView = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePickerView) {
            ImagePicker(sourceType: imageSource) { image in
                sendImageMessage(image: image)
            }
        }
        .onAppear {
            socketManager.joinRoom(name: "\(senderId)\(receiverId)")
            socketManager.goOnline()
            startTimer()
            router.isTabBarHidden = true
        }
        .onDisappear {
            stopTimer()
            socketManager.goOffline()
            router.isTabBarHidden = false
        }
    }
    struct ChatInputBar: View {
        @Binding var messageText: String
        var onSend: () -> Void
        var onMicTap: () -> Void
        var onAttachmentTap: () -> Void
        var body: some View {
            HStack(spacing: 4) {
                HStack(spacing: 4) {
                    ZStack(alignment: .leading) {
                        if messageText.isEmpty {
                            Text("Type here...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.leading, 16)
                        }

                        TextField("", text: $messageText)
                            .foregroundColor(.white)
                            .accentColor(.yellow)
                            .padding(.leading, 12)
                    }
                    Button(action: onAttachmentTap) {
                        Image(systemName: "paperclip")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.trailing, 12)
                    }
                }
                .frame(height: 48)
                .background(Color.black)
                .cornerRadius(24)
                Button {
                    messageText.isEmpty ? onMicTap() : onSend()
                } label: {
                    Image(systemName: messageText.isEmpty ? "mic.fill" : "paperplane.fill")
                        .foregroundColor(.black)
                        .frame(width: 48, height: 48)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(Color.clear)
        }
    }
    func sendImageMessage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("❌ Failed to convert image")
            return
        }
        let base64String = imageData.base64EncodedString()
        let dataPrefix = "data:image/jpeg;base64,"
        let imageBase64 = dataPrefix + base64String
        let payload: [String: Any] = [
            "type": "file",
            "sender_id": senderId,
            "sent_by": senderId,
            "receiver_id": receiverId,
            "chatId": chatId,
            "message": "",
            "connection_id": "\(receiverId)\(senderId)",
            "imageData": imageBase64
        ]
        print("📤 Emitting image payload: \(payload)")
        let newMessage = Message(
            id: Int.random(in: 1...Int.max),
            sentby: senderId,
            chat_id: chatId,
            type: "file",
            message: "",
            file:imageBase64,
            isSeen: "0"
        )
        socketManager.messages.append(newMessage)
        socketManager.sendMessage(msg: payload)
    }
    func scrollToLast(scrollViewProxy: ScrollViewProxy) {
        if let lastMessage = combinedMessages.last {
            withAnimation {
                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        let newMessage = Message(
            id: Int.random(in: 1...Int.max),
            sentby: senderId,
            chat_id: chatId,
            type: "text",
            message: trimmedText,
            file:"",
            isSeen: "0"
        )
        socketManager.messages.append(newMessage)
        let messagePayload: [String: Any] = [
            "type": "text",
            "sender_id": senderId,
            "sent_by": senderId,
            "receiver_id": receiverId,
            "chatId": chatId,
            "message": trimmedText,
            "connection_id": "\(receiverId)\(senderId)"
        ]
        socketManager.sendMessage(msg: messagePayload)
        userStoppedTyping()
        DispatchQueue.main.async {
          messageText = ""
        }
    }
    func userStartedTyping() {
        if !isTyping {
            isTyping = true
            let payload: [String: Any] = [
                "chat_id": chatId,
                "sender_id": senderId,
                "receiver_id": receiverId,
                "typing": true
            ]
            socketManager.sendTypingStatus(msg: payload)
        }
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            userStoppedTyping()
        }
    }
    func userStoppedTyping() {
        isTyping = false
        let payload: [String: Any] = [
            "chatId": chatId,
            "sender_id": senderId,
            "receiver_id": receiverId,
            "typing": false
        ]
        socketManager.sendTypingStatus(msg: payload)
    }
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            socketManager.checkIfUserOnline()
            socketManager.markMessageAsSeen()
        }
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
struct OnlineStatusView: View {
    let isOnline: Bool?
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill((isOnline ?? false) ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text((isOnline ?? false) ? "Online" : "Offline")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
struct ChatBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let UserImg: String
    let isSeen: String
    var body: some View {
        HStack(alignment: .bottom) {
            if isCurrentUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    contentView()
                        .padding([.leading, .trailing], 10)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(16)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                    seenView()
                }
            } else {
                    VStack(alignment: .leading, spacing: 4) {
                        contentView()
                            .background(AppColors.primaryYellow)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.primaryYellow.opacity(0.3), lineWidth: 1)
                            )
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    }
                    Spacer()
                
              }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    @ViewBuilder
    private func contentView() -> some View {
        if message.type == "file" {
            if let filePath = message.file, let url = URL(string:filePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: 200, maxHeight: 200)
            } else {
                Text("Invalid image")
                    .foregroundColor(.red)
                    .padding(10)
            }
        } else {
            Text(message.message ?? "")
                .padding(10)
                .font(AppFont.manropeSemiBold(14))
                .foregroundColor(.black)
        }
    }
    @ViewBuilder
    private func seenView() -> some View {
        HStack(spacing: -4) {
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundColor(isSeen == "1" ? .blue : .gray)
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundColor(isSeen == "1" ? .blue : .gray)
        }
        .padding(.trailing, 8)
        .padding(.bottom, 4)
    }
}
