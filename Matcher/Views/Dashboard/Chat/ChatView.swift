import SwiftUI
import Speech
import AVFoundation
import AVKit
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
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordedAudioURL: URL?
    @State private var isRecording = false
    @EnvironmentObject var chatVM: ChatsModel
    let senderId: Int
    let chatId: Int
    let receiverId: Int
    let UserImg: String
    let userName: String
    var combinedMessages: [Message] {
        Chats.messages + socketManager.messages
    }
    let chat: Chat?
    init(senderId: Int, chatId: Int, receiverId: Int, UserImg: String, userName: String, chat: Chat? = nil) {
        self.senderId = senderId
        self.chatId = chatId
        self.receiverId = receiverId
        self.UserImg = UserImg
        self.userName = userName
        self.chat = chat
        print("""
            🟢 ChatView init called
            ├─ senderId: \(senderId)
            ├─ chatId: \(chatId)
            ├─ receiverId: \(receiverId)
            ├─ UserImg: \(UserImg)
            └─ userName: \(userName)
            """)
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
                    showEmojiPicker: $showEmojiPicker,
                    isRecording: isRecording,
                    onSend: {
                        sendMessage()
                        stopRecording()
                    },
                    onMicTap: {
                        isRecording ? stopRecording() : startRecording()
                    },
                    onAttachmentTap: {
                        showImagePicker = true
                    },
                    onTyping: {
                        userStartedTyping()
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
        .onChange(of: isRecording) { oldValue, newValue in
            print("Recording changed:", oldValue, "→", newValue)
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
            stopRecording()
            stopTimer()
            socketManager.goOffline()
            router.isTabBarHidden = false
        }
    }
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true)
        let fileName = UUID().uuidString + ".m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        recordedAudioURL = url
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        isRecording = true
        print("🎙️ Recording started")
    }
    func stopRecording() {
        guard isRecording else { return }
        audioRecorder?.stop()
        isRecording = false
        print("🛑 Recording stopped safely")
        if let url = recordedAudioURL {
            sendAudioMessage(url: url)
        }
    }
    func sendAudioMessage(url: URL) {
        guard let audioData = try? Data(contentsOf: url) else {
            print("❌ Failed to read audio file")
            return
        }
        let base64Audio = audioData.base64EncodedString()
        let audioPayload = "data:audio/m4a;base64," + base64Audio
        let payload: [String: Any] = [
            "type": "file",
            "sender_id": senderId,
            "sent_by": senderId,
            "receiver_id": receiverId,
            "chatId": chatId,
            "message": "",
            "connection_id": "\(receiverId)\(senderId)",
            "audioData": audioPayload
        ]
        let newMessage = Message(
            id: Int.random(in: 1...Int.max),
            sentby: senderId,
            chat_id: chatId,
            type: "audio",
            message: "",
            file: url.absoluteString,
            isSeen: "0"
        )
        if self.chat != nil {
        chatVM.updateLastMessageLocally(message: newMessage, isIncoming: false)
        }
        socketManager.messages.append(newMessage)
        socketManager.sendMessage(msg: payload)
        print("📤 Audio message sent to socket")
    }
    struct ChatInputBar: View {
        @Binding var messageText: String
        @Binding var showEmojiPicker: Bool
        let isRecording: Bool
        var onSend: () -> Void
        var onMicTap: () -> Void
        var onAttachmentTap: () -> Void
        var onTyping: () -> Void
        var body: some View {
            VStack(spacing: 4) {
                if isRecording {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.2)
                            .animation(
                                .easeInOut(duration: 0.8).repeatForever(),
                                value: isRecording
                        )
                        Text("Recording...")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                HStack(spacing: 4) {
                    Button {
                        showEmojiPicker = true
                    } label: {
                        Image(systemName: "face.smiling")
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(AppColors.Blue)
                            .clipShape(Circle())
                    }
                    HStack(spacing: 4) {
                        ZStack(alignment: .leading) {
                            if messageText.isEmpty {
                                Text("Type here...")
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.leading, 16)
                            }
                            TextField("", text: $messageText)
                                .onChange(of: messageText) {
                                    print("Entered text: \(messageText)")
                                    onTyping()
                                }
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
                    .background(AppColors.Black)
                    .cornerRadius(24)
                    Button {
                        messageText.isEmpty ? onMicTap() : onSend()
                    } label: {
                        Image(systemName: messageText.isEmpty ? "mic.fill" : "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(isRecording ? AppColors.primaryRed : AppColors.Blue)
                            .clipShape(Circle())
                            .scaleEffect(isRecording ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isRecording)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
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
            type: "image",
            message: "",
            file:imageBase64,
            isSeen: "0"
        )
        if chat != nil {
        chatVM.updateLastMessageLocally(message: newMessage, isIncoming: false)
        }
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
        if chat != nil {
        chatVM.updateLastMessageLocally(message: newMessage, isIncoming: false)
        }
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
        switch message.type {
        case "file":
            if let filePath = message.file {
                switch detectFileType(from: filePath) {
                case .image:
                    if let url = URL(string: filePath) {
                        ChatImageView(imageURL: url)
                    }
                case .audio:
                    AudioMessageView(audioURL: audioURL(from: filePath))
                case .unknown:
                    Text("Unsupported file")
                        .foregroundColor(.red)
                }
            }
        case "image":
            if let filePath = message.file,
               let url = URL(string: filePath) {
                ChatImageView(imageURL: url)
            }
        case "audio":
            if let file = message.file, let url = URL(string: file) {
                AudioLocalView(audioURL: url)
            }
        default:
            Text(message.message ?? "")
                .padding(10)
                .font(AppFont.manropeSemiBold(14))
                .foregroundColor(.black)
        }
    }
    private func audioURL(fromBase64 base64: String) -> URL? {
        let cleanBase64 = base64
            .replacingOccurrences(of: "data:audio/m4a;base64,", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let audioData = Data(base64Encoded: cleanBase64) else {
            print("❌ Base64 decode failed")
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")

        do {
            try audioData.write(to: url)
            return url
        } catch {
            print("❌ File write failed:", error)
            return nil
        }
    }
    private func audioURL(from path: String) -> URL {
        if path.starts(with: "http") {
            return URL(string: path)!
        } else {
            return URL(fileURLWithPath: path)
        }
    }
    private func detectFileType(from path: String) -> FileType {
        if path.lowercased().hasSuffix(".m4a") || path.lowercased().hasSuffix(".mp3") {
            return .audio
        } else if path.lowercased().hasSuffix(".jpg") || path.lowercased().hasSuffix(".jpeg") || path.lowercased().hasSuffix(".png") {
            return .image
        } else {
            return .unknown
        }
    }
    enum FileType {
        case image, audio, unknown
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
    struct ChatImageView: View {
        let imageURL: URL
        var body: some View {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: 220, maxHeight: 220)
        }
}
struct AudioLocalView: View {
    let audioURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 1
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any?
    var body: some View {
        HStack(spacing: 12) {
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(isPlaying ? "Playing…" : "Voice message")
                    .font(.subheadline)
                if duration > 0 {
                    ProgressView(value: isPlaying ? progress : 1)
                        .progressViewStyle(.linear)
                        .frame(height: 4)
                }
                HStack {
                    Text(formatTime(isPlaying ? currentTime : duration))
                    Spacer()
                    Text(formatTime(duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            configureAudioSession()
            preloadDuration()
        }
        .onDisappear {
            stopPlayer()
        }
    }
    private func togglePlay() {
        if player == nil {
            player = AVPlayer(url: audioURL)
            addProgressObserver()
            addFinishObserver()
        }
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    private func preloadDuration() {
        let asset = AVAsset(url: audioURL)
        Task {
            do {
                let durationTime = try await asset.load(.duration)
                let seconds = durationTime.seconds
                if seconds.isFinite {
                    await MainActor.run {
                        duration = seconds
                    }
                }
            } catch {
                print("❌ Failed to load duration:", error)
            }
        }
    }
    private func addProgressObserver() {
        guard let player else { return }
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { time in
            currentTime = time.seconds

            if duration > 0 {
                progress = currentTime / duration
            }
        }
    }
    private func addFinishObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            stopPlayer()
        }
    }
    private func stopPlayer() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player?.seek(to: .zero)
        player = nil
        isPlaying = false
        progress = 1
        currentTime = 0
    }
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("❌ AVAudioSession error:", error)
        }
    }
    private func formatTime(_ time: Double) -> String {
        guard time.isFinite else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
struct AudioMessageView: View {
    let audioURL: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Button(action: togglePlay) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(isPlaying ? "Playing..." : "Voice message")
                        .font(.subheadline)
                    if duration > 0 {
                        ProgressView(
                            value: isPlaying ? progress : duration,
                            total: duration
                        )
                        .progressViewStyle(.linear)
                        .frame(height: 4)
                    }
                    HStack {
                        Text(formatTime(isPlaying ? progress : duration))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .onAppear {
            configureAudioSession()
            preloadDuration()
        }
        .onDisappear {
            stopPlayer()
        }
    }
    private func togglePlay() {
        if player == nil {
            loadAudio()
            return
        }
        isPlaying ? pause() : play()
    }
    private func loadAudio() {
        if audioURL.isFileURL {
            setupPlayer(with: audioURL)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: audioURL)
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + ".m4a")
                    try data.write(to: tempURL)

                    DispatchQueue.main.async {
                        setupPlayer(with: tempURL)
                    }
                } catch {
                    print("❌ Audio load failed:", error)
                }
            }
        }
    }
    private func setupPlayer(with url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            play()
        } catch {
            print("❌ Player error:", error)
        }
    }
    private func play() {
        player?.play()
        isPlaying = true
        startProgressTimer()
    }
    private func pause() {
        player?.pause()
        isPlaying = false
        stopProgressTimer()
    }
    private func stopPlayer() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        stopProgressTimer()
    }
    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player else { return }
            progress = player.currentTime

            if player.currentTime >= player.duration {
                stopPlayer()
            }
        }
    }
    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
        } catch {
            print("❌ Audio session error:", error)
        }
    }
    private func preloadDuration() {
        guard duration == 0 else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: audioURL)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".m4a")
                try data.write(to: tempURL)

                let tempPlayer = try AVAudioPlayer(contentsOf: tempURL)
                DispatchQueue.main.async {
                    duration = tempPlayer.duration
                }
            } catch {
                print("❌ Duration preload failed:", error)
            }
        }
    }
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
class AVPlayerDelegateWrapper: NSObject, AVAudioPlayerDelegate {
    private let onFinish: (Bool) -> Void
    init(onFinish: @escaping (Bool) -> Void) {
        self.onFinish = onFinish
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish(flag)
    }
}




