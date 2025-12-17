//
//  Constants.swift
//  Attendance
//
//  Created by POSSIBILITY on 24/04/25.
//

import Foundation

func formattedDate(from string: String?, format: String = "MMM d, yyyy 'at' h:mm a") -> String {
    guard let string = string else { return "N/A" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    if let date = formatter.date(from: string) {
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    return "Invalid date"
}
func isValidEmail(_ email: String) -> Bool {
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: email)
}
func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}
func formatDuration(from start: Date, to end: Date) -> String {
       let interval = Int(end.timeIntervalSince(start))
       let hours = interval / 3600
       let minutes = (interval % 3600) / 60
       let seconds = interval % 60
       return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
   }
