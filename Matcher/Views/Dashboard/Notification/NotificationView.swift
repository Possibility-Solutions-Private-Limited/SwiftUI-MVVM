import SwiftUI

struct NotificationView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @StateObject var notification = NotificationsModel()
    private let spacing: CGFloat = 14
    private let horizontalPad: CGFloat = 15
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
                        if notification.notificationData.isEmpty {
                            NoRoomsView()
                        }else{
                            ScrollView(showsIndicators: false) {
                                ForEach(notification.notificationData) { user in
                                    NotificationRow(notification: user)
                                        .id(user.id)
                                        .onAppear {
                                            if user.id == notification.notificationData.last?.id {
                                                notification.loadMoreNew()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            notification.fetchNotification()
        }
    }
    struct NoRoomsView: View {
        var body: some View {
            VStack(spacing: 0) {
                Image("likiy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("No Matches Nearby")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(.black)
                Text("Try changing your location or preferences ")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .tabBar)
        }
    }
    private var header: some View {
        HStack {
            Spacer()
            Text("Notifications")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top,30)
        .padding(.bottom,20)
    }
}
struct NotificationRow: View {
    let notification: NotificationData
    @StateObject private var loader = ImageLoader()

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            let photoURL = notification.senderDetail.photos.first?.file
            Group {
                if let uiImage = loader.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else if let url = photoURL, !url.isEmpty {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .onAppear {
                            loader.load(from: url)
                        }
                } else {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                  }
             }
            VStack(alignment: .leading, spacing: 6) {
                Text(notification.senderDetail.firstName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                Text(notification.message)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                    .lineLimit(2)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: Color.gray.opacity(0.25),
                    radius: 6,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, 20)
    }
}


