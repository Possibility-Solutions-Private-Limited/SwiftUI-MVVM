import SwiftUI
import UIKit
struct BoxItem: Identifiable {
    var id = UUID()
    var color: Color
    var label: String
    var description: String
}
struct ColoredBoxView: View {
    var item: BoxItem
    var body: some View {
        VStack {
            Text(item.label)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(item.color)
                .cornerRadius(8)
            Text(item.description)
                .foregroundColor(.white)
                .padding()
                .background(item.color.opacity(0.8))
                .cornerRadius(8)
        }
        .padding(10)
        .background(item.color.opacity(0.3))
        .cornerRadius(8)
    }
}
struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    let items: [BoxItem] = [
        BoxItem(color: .blue, label: "Box 1", description: "This is a description for box 1. It is a bit longer to demonstrate dynamic height."),
        BoxItem(color: .green, label: "Box 2", description: "Short description."),
        BoxItem(color: .red, label: "Box 3", description: "This is another description. This one is also long to show how the height adjusts."),
        BoxItem(color: .orange, label: "Box 4", description: "Another short description."),
        BoxItem(color: .green, label: "Box 5", description: "This description is medium length."),
        BoxItem(color: .purple, label: "Box 6", description: "This description is medium length."),

        BoxItem(color: .orange, label: "Box 7", description: "This description is medium length."),
        BoxItem(color: .red, label: "Box 8", description: "This description is medium length."),
        BoxItem(color: .green, label: "Box 9", description: "This description is medium length."),
        BoxItem(color: .blue, label: "Box 10", description: "This description is medium length. again This description is medium length"),

    ]
    // Define the layout for the grid
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        VStack {
            // MARK: - Custom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                Text("detail")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items) { item in
                            ColoredBoxView(item: item)
                        }
                    }
                    .padding()
                }
            }
        }.toolbar(.hidden, for: .navigationBar)
    }
}
