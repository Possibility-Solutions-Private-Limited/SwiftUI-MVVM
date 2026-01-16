import Foundation
import SocketIO
class SocketService: ObservableObject {
    private var manager: SocketManager
    private var socket: SocketIOClient
    @Published var messages: [Message] = []
    @Published var isOtherUserOnline: Bool? = nil
    private var roomNameToJoin: String? = nil
    @Published var isOtherUserTyping: Bool = false
    private var senderId: String
    private var receiverId: String
    private var chatId: Int
    weak var chatVM: ChatsModel?
    weak var InteractionVM: InteractionModel?
    init(senderId: Int, receiverId: Int, chatId: Int, chat: Chat? = nil, chatVM: ChatsModel? = nil) {
        self.senderId = "\(senderId)"
        self.receiverId = "\(receiverId)"
        self.chatId = chatId
        let socketUrl = URL(string: APIConstants.socketURL)!
        self.manager = SocketManager(socketURL: socketUrl, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        setupHandlers()
        socket.connect()
    }
    func injectInteractionVM(_ vm: InteractionModel) {
        self.InteractionVM = vm
    }
    func injectChatVM(_ vmc: ChatsModel) {
        self.chatVM = vmc
    }
    private func setupHandlers() {
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self = self else { return }
            print("✅ Socket connected")
            if let room = self.roomNameToJoin {
                self.socket.emit("join", room)
                print("🔗 Joined room: \(room)")
            }
            self.socket.emit("online", [
                "receiver_id": self.receiverId,
                "sender_id": self.senderId
            ])
        }
        socket.on("userOnline") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let online = dict["online"] as? Bool else { return }
            DispatchQueue.main.async {
                self?.isOtherUserOnline = online
                print("🟢 Other user is online: \(online)")
            }
        }
        socket.on("userOffline") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let online = dict["online"] as? Bool else { return }
            DispatchQueue.main.async {
                self?.isOtherUserOnline = online
                print("🔴 Other user is offline")
            }
        }
        socket.on("receivedMessage") { [weak self] data, _ in
            guard let self = self,
                  let first = data.first as? [String: Any] else {
                print("❌ Invalid message format")
                return
            }
            let messageText = first["message"] as? String ?? ""
            let type = first["type"] as? String ?? "text"
            let file = first["file"] as? String ?? ""
            let isSeen = first["is_seen"] as? String ?? ""
            let chatId = first["chat_id"] as? Int ?? self.chatId
            var senderIdStr = ""
            if let id = first["sent_by"] as? Int {
                senderIdStr = String(id)
            } else if let id = first["sent_by"] as? String {
                senderIdStr = id
            }
            DispatchQueue.main.async {
                if let idInt = Int(senderIdStr) {
                    let newMsg = Message(
                        id: Int.random(in: 1...Int.max),
                        sentby: idInt,
                        chat_id: chatId,
                        type: type,
                        message: messageText,
                        file: file,
                        isSeen: isSeen
                    )
                    self.messages.append(newMsg)
                    Task { @MainActor in
                        self.chatVM?.updateLastMessage(message: newMsg, isIncoming: false)
                    }
                    print("📩 Message received: \(newMsg)")
                } else {
                    print("⚠️ Invalid sender ID")
                }
            }
        }
        socket.on("seen") { data, ack in
            guard let dict = data[0] as? [String: Any] else { return }
            print("dict",dict)
            if let chatId = dict["chat_id"] as? Int {
                for (i, msg) in self.messages.enumerated() where msg.chat_id == chatId {
                    self.messages[i].isSeen = "1"
                }
            }
        }
        socket.on("typingStatus") { [weak self] data, _ in
            guard let self = self,
                  let dict = data.first as? [String: Any],
                  let typing = dict["typing"] as? Bool else { return }
               DispatchQueue.main.async {
                self.isOtherUserTyping = typing
             }
        }
    }
    func sendMessage(msg: [String: Any]) {
        socket.emitWithAck("sendMessage", msg).timingOut(after: 1) { response in
            guard let first = response.first as? [String: Any],
                  let chatId = first["chat_id"] as? Int else {
                print("⚠️ No valid chat_id received")
                return
            }
            Task { @MainActor in
                if self.chatId == 0 {
                    let oldId = Int(self.receiverId) ?? 0
                    self.InteractionVM?.updateChatId(newId: chatId, oldId: oldId)
                    KeychainHelper.shared.saveInt(1, forKey: "shouldReloading")
                }
                self.chatId = chatId
            }
        }
    }
    func goOnline() {
        if socket.status == .connected {
            socket.emit("online", [
                "sender_id": senderId,
                "receiver_id": receiverId
            ])
        }
    }
    func checkIfUserOnline() {
        let payload: [String: Any] = [
            "sender_id": receiverId,
            "receiver_id": senderId
        ]
        socket.emit("checkOnline", payload)
    }
    func goOffline() {
        socket.emit("offline", [
            "sender_id": senderId,
            "receiver_id": receiverId
        ])
    }
    func joinRoom(name: String) {
        if socket.status == .connected {
            socket.emit("join", name)
        } else {
            roomNameToJoin = name
        }
    }
    func markMessageAsSeen() {
        print(chatId,senderId,receiverId)
        let seenData: [String: Any] = [
            "chat_id": chatId,
            "sender_id": senderId,
            "receiver_id": receiverId,
        ]
        socket.emit("seen", seenData)
    }
    func destroy(msg: [String: Any]) {
        socket.emit("destroy", msg)
    }
    func sendTypingStatus(msg: [String: Any]) {
        socket.emit("typingStatus", msg)
    }
    func disconnect() {
        goOffline()
        socket.disconnect()
    }
}
