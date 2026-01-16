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
    func messageExists(id: Int) -> Bool {
        let sql = "SELECT 1 FROM messages WHERE id = ? LIMIT 1;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        sqlite3_bind_int64(stmt, 1, sqlite3_int64(id))
        let exists = sqlite3_step(stmt) == SQLITE_ROW
        sqlite3_finalize(stmt)
        return exists
    }
    func saveMessages(_ messages: [Message]) {
        let sql = """
        INSERT OR REPLACE INTO messages
        (id, sent_by, type, message, file, is_seen)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("❌ Prepare failed:", String(cString: sqlite3_errmsg(db)))
            return
        }
        for msg in messages {
            sqlite3_bind_int64(stmt, 1, sqlite3_int64(msg.id))
            sqlite3_bind_int64(stmt, 2, sqlite3_int64(msg.sentby))
            sqlite3_bind_text(stmt, 3, msg.type?.cString(using: .utf8), -1, transient)
            sqlite3_bind_text(stmt, 4, msg.message?.cString(using: .utf8), -1, transient)
            sqlite3_bind_text(stmt, 5, msg.file?.cString(using: .utf8), -1, transient)
            sqlite3_bind_text(stmt, 6, msg.isSeen.cString(using: .utf8), -1, transient)
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("❌ Insert failed:", String(cString: sqlite3_errmsg(db)))
            }
            sqlite3_reset(stmt)
            sqlite3_clear_bindings(stmt)
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
