import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var notification = NotificationsModel()
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
                    if notification.notificationData.isEmpty && !notification.isLoading {
                        NoRoomsView()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: spacing) {
                                ForEach(notification.notificationData) { user in
                                    NotificationRow(notification: user) {
                                        notification.deleteNotification(id: user.id)
                                    }
                                    .id(user.id)
                                }
                                if notification.isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                }
            }
        }
        .onAppear {
            if notification.notificationData.isEmpty {
                notification.fetchNotification()
            }
        }
    }
    struct NoRoomsView: View {
        var body: some View {
            VStack(spacing: 8) {
                Image("notification")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("No Notifications Yet")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(.black)
                Text("You haven’t received any notifications yet. Check back later for updates.")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
}
struct NotificationRow: View {
    let notification: NotificationData
    var onDelete: () -> Void
    @StateObject private var loader = ImageLoader()
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            let photoURL = notification.senderDetail.photos.first?.file
            Group {
                if let uiImage = loader.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .onAppear {
                            if let url = photoURL, !url.isEmpty {
                                loader.load(from: url)
                            }
                        }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(notification.senderDetail.firstName)
                    .font(.system(size: 15, weight: .semibold))
                Text(notification.message)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                    .lineLimit(2)
            }
            Spacer()
            Button {
                showDeleteAlert = true
            } label: {
                if isDeleting {
                    ProgressView()
                        .frame(width: 32, height: 32)
                } else {
                    Image("delete")
                }
            }
            .disabled(isDeleting)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.25), radius: 6, y: 4)
        )
        .padding(.horizontal, 20)
        .alert(
            "Delete Notification",
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                isDeleting = true
                onDelete()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isDeleting = false
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this?")
        }
    }
}




