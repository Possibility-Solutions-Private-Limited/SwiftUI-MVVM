import Foundation
import SQLite3

final class MessageSQLite {
    private var db: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private let chatId: Int
    init(chatId: Int) {
        self.chatId = chatId
        openDB(chatId: chatId)
        createTable()
    }
    private func openDB(chatId: Int) {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("messages_\(chatId).sqlite")
        if sqlite3_open(url.path, &db) == SQLITE_OK {
            print("✅ Messages DB opened for chat \(chatId)")
        } else {
            print("❌ Failed to open Messages DB")
        }
    }
    private let createMessagesTable = """
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY,
        sent_by INTEGER NOT NULL,
        type TEXT,
        message TEXT,
        file TEXT,
        is_seen TEXT DEFAULT '0'
    );
    """
    private func createTable() {
        if sqlite3_exec(db, createMessagesTable, nil, nil, nil) != SQLITE_OK {
            let error = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to create messages table: \(error)")
        }
    }
    func saveMessages(_ messages: [Message]) {
        let sql = """
        INSERT OR REPLACE INTO messages
        (id, sent_by, type, message, file, is_seen)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            for msg in messages {
                sqlite3_bind_int(stmt, 1, Int32(msg.id))
                sqlite3_bind_int(stmt, 2, Int32(msg.sentby))
                sqlite3_bind_text(stmt, 3, msg.type ?? "", -1, transient)
                sqlite3_bind_text(stmt, 4, msg.message ?? "", -1, transient)
                sqlite3_bind_text(stmt, 5, msg.file ?? "", -1, transient)
                sqlite3_bind_text(stmt, 6, msg.isSeen, -1, transient)

                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("❌ Failed to save message:", String(cString: sqlite3_errmsg(db)))
                }
                sqlite3_reset(stmt)
            }
        }
        sqlite3_finalize(stmt)
    }
    func fetchMessages() -> [Message] {
        var messages: [Message] = []
        let sql = """
        SELECT id, sent_by, type, message, file, is_seen
        FROM messages
        ORDER BY id ASC;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let msg = Message(
                    id: Int(sqlite3_column_int(stmt, 0)),
                    sentby: Int(sqlite3_column_int(stmt, 1)),
                    chat_id: chatId,
                    type: sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) },
                    message: sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) },
                    file: sqlite3_column_text(stmt, 4).flatMap { String(cString: $0) },
                    isSeen: sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) } ?? "0"
                )
                messages.append(msg)
            }
        }
        sqlite3_finalize(stmt)
        return messages
    }
    func clearMessages() {
        let sql = "DELETE FROM messages;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
}
