import Foundation
import SQLite3

final class ChatListSQLite {
    static let shared = ChatListSQLite()
    private var db: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private init() {
        openDB(userId: KeychainHelper.shared.getInt(forKey: "userId") ?? 0)
        createTables()
    }
    private func openDB(userId: Int) {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("chat_\(userId).sqlite")
        if sqlite3_open(url.path, &db) == SQLITE_OK {
            print("✅ Database opened at \(url.path)")
        } else {
            print("❌ Failed to open DB")
        }
    }
    private func createTables() {
        let chats = """
        CREATE TABLE IF NOT EXISTS chats (
            id INTEGER PRIMARY KEY,
            sender_id INTEGER,
            receiver_id INTEGER,
            created_at TEXT,
            unseen_count INTEGER
        );
        """
        let messages = """
        CREATE TABLE IF NOT EXISTS last_messages (
            id INTEGER PRIMARY KEY,
            chat_id INTEGER,
            message TEXT,
            file TEXT,
            type TEXT,
            is_seen TEXT,
            created_at TEXT
        );
        """
        let users = """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            mobile TEXT,
            gender TEXT,
            dob TEXT,
            lat TEXT,
            long TEXT,
            location TEXT,
            page_key INTEGER,
            image TEXT
        );
        """
        let photos = """
        CREATE TABLE IF NOT EXISTS photos (
            id INTEGER PRIMARY KEY,
            user_id INTEGER,
            file TEXT,
            file_type TEXT,
            thumbnail TEXT
        );
        """
        [chats, messages, users, photos].forEach {
            if sqlite3_exec(db, $0, nil, nil, nil) != SQLITE_OK {
                let error = String(cString: sqlite3_errmsg(db))
                print("❌ Failed to create table: \(error)")
            }
        }
    }
    func saveChats(_ chats: [Chat]) {
        for chat in chats { saveOrUpdateChat(chat) }
    }
    func clearAllChats() {
        let queries = [
            "DELETE FROM chats;",
            "DELETE FROM users;",
            "DELETE FROM user_photos;",
            "DELETE FROM last_messages;"
        ]
        for sql in queries {
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }
    private func chatExists(chatId: Int) -> Bool {
        let sql = "SELECT 1 FROM chats WHERE id = ? LIMIT 1;"
        var stmt: OpaquePointer?
        var exists = false
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(chatId))
            if sqlite3_step(stmt) == SQLITE_ROW {
                exists = true
            }
        }
        sqlite3_finalize(stmt)
        return exists
    }
    func saveOrUpdateChat(_ chat: Chat) {
        let exists = chatExists(chatId: chat.id)
        let chatSQL = """
        INSERT OR REPLACE INTO chats
        (id, sender_id, receiver_id, created_at, unseen_count)
        VALUES (?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, chatSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(chat.id))
            sqlite3_bind_int(stmt, 2, Int32(chat.senderDetail.id ?? 0))
            sqlite3_bind_int(stmt, 3, Int32(chat.receiverDetail.id ?? 0))
            sqlite3_bind_text(stmt, 4, chat.createdAt, -1, transient)
            sqlite3_bind_int(stmt, 5, Int32(chat.unseen_message_count ?? 0))
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("❌ Chat save failed:", String(cString: sqlite3_errmsg(db)))
            } else {
                print("✅ Chat row \(exists ? "UPDATED" : "INSERTED") successfully")
            }
        } else {
            print("❌ Prepare chat failed:", String(cString: sqlite3_errmsg(db)))
        }
        sqlite3_finalize(stmt)
        if let msg = chat.lastMessage {
            saveLastMessage(msg, chatId: chat.id)
        }
        saveUser(chat.senderDetail)
        saveUser(chat.receiverDetail)
    }
    private func saveLastMessage(_ msg: LastMessage, chatId: Int) {
        let sql = """
        INSERT OR REPLACE INTO last_messages
        (id, chat_id, message, file, type, is_seen, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt, 1, sqlite3_int64(msg.id))
            sqlite3_bind_int64(stmt, 2, sqlite3_int64(chatId))
            sqlite3_bind_text(stmt, 3, msg.message ?? "", -1, transient)
            sqlite3_bind_text(stmt, 4, msg.file ?? "", -1, transient)
            sqlite3_bind_text(stmt, 5, msg.type ?? "", -1, transient)
            sqlite3_bind_text(stmt, 6, msg.isSeen, -1, transient)
            sqlite3_bind_text(stmt, 7, msg.createdAt, -1, transient)
            if sqlite3_step(stmt) != SQLITE_DONE {
                let error = String(cString: sqlite3_errmsg(db))
                print("❌ Failed to save last message: \(error)")
            }
        } else {
            let error = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to prepare statement: \(error)")
        }
        sqlite3_finalize(stmt)
    }
    private func saveUser(_ user: User) {
        let image = user.photos?.first?.file ?? ""
        let sql = """
        INSERT OR REPLACE INTO users
        (id, first_name, last_name, email, mobile, gender, dob, lat, long, location, page_key, image)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(user.id ?? 0))
            sqlite3_bind_text(stmt, 2, user.firstName ?? "", -1, transient)
            sqlite3_bind_text(stmt, 3, user.lastName ?? "", -1, transient)
            sqlite3_bind_text(stmt, 4, user.email ?? "", -1, transient)
            sqlite3_bind_text(stmt, 5, user.mobile ?? "", -1, transient)
            sqlite3_bind_text(stmt, 6, user.gender ?? "", -1, transient)
            sqlite3_bind_text(stmt, 7, user.dob ?? "", -1, transient)
            sqlite3_bind_text(stmt, 8, user.lat ?? "", -1, transient)
            sqlite3_bind_text(stmt, 9, user.long ?? "", -1, transient)
            sqlite3_bind_text(stmt, 10, user.location ?? "", -1, transient)
            sqlite3_bind_int(stmt, 11, Int32(user.pageKey ?? 0))
            sqlite3_bind_text(stmt, 12, image, -1, transient)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        user.photos?.forEach { savePhoto($0, userId: user.id ?? 0) }
    }
    private func savePhoto(_ photo: Photo, userId: Int) {
        let sql = """
        INSERT OR REPLACE INTO photos (id, user_id, file, file_type, thumbnail)
        VALUES (?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(photo.id ?? 0))
            sqlite3_bind_int(stmt, 2, Int32(userId))
            sqlite3_bind_text(stmt, 3, photo.file ?? "", -1, transient)
            sqlite3_bind_text(stmt, 4, photo.fileType ?? "", -1, transient)
            sqlite3_bind_text(stmt, 5, photo.thumbnail ?? "", -1, transient)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    func fetchChats() -> [Chat] {
        var result: [Chat] = []
        let query = "SELECT * FROM chats ORDER BY id DESC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let senderId = Int(sqlite3_column_int(stmt, 1))
                let receiverId = Int(sqlite3_column_int(stmt, 2))
                let createdAt = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) } ?? ""
                let unseenCount = Int(sqlite3_column_int(stmt, 4))
                let sender = fetchUser(userId: senderId)
                let receiver = fetchUser(userId: receiverId)
                let lastMessage = fetchLastMessage(chatId: id)
                let chat = Chat(
                    id: id,
                    senderDetail: sender,
                    receiverDetail: receiver,
                    lastMessage: lastMessage,
                    createdAt: createdAt,
                    unseen_message_count: unseenCount
                )
                result.append(chat)
            }
        } else {
            let error = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to fetch chats: \(error)")
        }
        sqlite3_finalize(stmt)
        return result
    }
    private func fetchUser(userId: Int) -> User {
        let query = "SELECT * FROM users WHERE id = ?;"
        var stmt: OpaquePointer?
        var user = User(id: userId, firstName: "", lastName: "", email: nil, mobile: nil, gender: nil, dob: nil, lat: nil, long: nil, location: nil, pageKey: nil, photos: nil, profile: nil, chatting: nil, rooms: nil)
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(userId))
            if sqlite3_step(stmt) == SQLITE_ROW {
                let firstName = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
                let lastName = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
                let email = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) }
                let mobile = sqlite3_column_text(stmt, 4).flatMap { String(cString: $0) }
                let gender = sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) }
                let dob = sqlite3_column_text(stmt, 6).flatMap { String(cString: $0) }
                let lat = sqlite3_column_text(stmt, 7).flatMap { String(cString: $0) }
                let long = sqlite3_column_text(stmt, 8).flatMap { String(cString: $0) }
                let location = sqlite3_column_text(stmt, 9).flatMap { String(cString: $0) }
                let pageKey = Int(sqlite3_column_int(stmt, 10))
                let photos = fetchPhotos(userId: userId)
                user = User(
                    id: userId,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    mobile: mobile,
                    gender: gender,
                    dob: dob,
                    lat: lat,
                    long: long,
                    location: location,
                    pageKey: pageKey,
                    photos: photos,
                    profile: nil,
                    chatting: nil,
                    rooms: nil
                )
            }
        }
        sqlite3_finalize(stmt)
        return user
    }
    private func fetchPhotos(userId: Int) -> [Photo] {
        var photos: [Photo] = []
        let query = "SELECT * FROM photos WHERE user_id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(userId))
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let file = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
                let fileType = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) } ?? ""
                let thumbnail = sqlite3_column_text(stmt, 4).flatMap { String(cString: $0) } ?? ""
                photos.append(Photo(id: id, file: file, fileType: fileType, thumbnail: thumbnail))
            }
        }
        sqlite3_finalize(stmt)
        return photos
    }
    private func fetchLastMessage(chatId: Int) -> LastMessage? {
        let query = "SELECT * FROM last_messages WHERE chat_id = ?;"
        var stmt: OpaquePointer?
        var message: LastMessage? = nil
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(chatId))
            if sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let messageText = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) }
                let fileText = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) }
                let typeText = sqlite3_column_text(stmt, 4).flatMap { String(cString: $0) }
                let isSeenText = sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) } ?? "0"
                let createdAtText = sqlite3_column_text(stmt, 6).flatMap { String(cString: $0) } ?? ""
                message = LastMessage(
                    id: id,
                    message: messageText,
                    file: fileText,
                    type: typeText,
                    isSeen: isSeenText,
                    createdAt: createdAtText
                )
            }
        }
        sqlite3_finalize(stmt)
        return message
    }
}
