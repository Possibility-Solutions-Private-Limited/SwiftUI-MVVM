import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging
import Foundation
import CoreLocation
@main
struct AttendanceApp: App {
    @StateObject private var userAuth = UserAuth()
    @StateObject private var router = AppRouter()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var location = LocationPermissionManager()
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(userAuth)
                .environmentObject(router)
                .environmentObject(location)
        }
    }
}
struct ContentView: View {
    @EnvironmentObject var userAuth:UserAuth
    var body: some View {
        Group {
            if userAuth.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}
// MARK: - APP ROUTER (Sample)
class AppRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var navigationPath = NavigationPath()
    @Published var senderId: Int = 0
    @Published var chatId: Int = 0
    @Published var receiverId: Int = 0
    @Published var userImg: String = ""
    @Published var userName: String = ""
}
// MARK: - MAIN VIEW (Side Menu + TabBar)
struct MainView: View {
    @EnvironmentObject var router: AppRouter
    @State private var showMenu: Bool = false
    @GestureState private var dragOffset: CGFloat = 0
    var body: some View {
        ZStack(alignment: .leading) {
            // MARK: - TabView as main content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .disabled(showMenu) // Disable interactions when menu is open
                .overlay(
                    Group {
                        if showMenu {
                            Color.black.opacity(0.25)
                                .ignoresSafeArea()
                                .onTapGesture { withAnimation { showMenu = false } }
                        }
                    }
                )
                .offset(x: showMenu ? 260 : 0)
                .offset(x: dragOffset)
                .animation(.easeInOut(duration: 0.25), value: showMenu)

            // MARK: - Side Menu
            SideMenuView(showMenu: $showMenu)
                .frame(width: 260)
                .offset(x: showMenu ? 0 : -260)
                .offset(x: dragOffset)
                .animation(.easeInOut(duration: 0.25), value: showMenu)
                .ignoresSafeArea()
        }
        .gesture(dragGesture)
    }

    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                let translation = value.translation.width
                if showMenu && translation < 0 { state = translation }      // Closing drag
                if !showMenu && translation > 0 { state = translation }     // Opening drag
            }
            .onEnded { value in
                let translation = value.translation.width
                if showMenu && translation < -80 { withAnimation { showMenu = false } }
                if !showMenu && translation > 80 { withAnimation { showMenu = true } }
            }
    }

    // MARK: - TabView Content
    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack(path: $router.navigationPath) {
                ChatListView()
                    .navigationDestination(for: String.self) { route in
                        if route == "ChatView" {
                            ChatView(
                                senderId: router.senderId,
                                chatId: router.chatId,
                                receiverId: router.receiverId,
                                UserImg: router.userImg,
                                userName: router.userName
                            )
                        }
                    }
            }
            .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
            .tag(1)

            NavigationStack {
                SettingView()
            }
            .tabItem { Label("Map", systemImage: "creditcard.fill") }
            .tag(2)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Setting", systemImage: "gearshape.fill") }
            .tag(3)
        }
    }
}
// MARK: - SIDE MENU VIEW
struct SideMenuView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var router: AppRouter
    var body: some View {
        VStack(alignment: .leading ,spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 52, height: 52)
                    .overlay(
                        Group {
                            if let url = URL(string: router.userImg), !router.userImg.isEmpty {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "person.fill").resizable().scaledToFit()
                                    }
                                }
                            } else {
                                Image(systemName: "person.fill").resizable().scaledToFit()
                            }
                        }
                    )
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(router.userName.isEmpty ? "Guest" : router.userName)
                        .font(.headline)
                    Text("View Profile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.horizontal)
            Divider()
            // Menu Items
            VStack(alignment: .leading, spacing: 5) {
                menuButton(title: "Home", systemImage: "house.fill", tab: 0)
                menuButton(title: "Chat", systemImage: "bubble.left.and.bubble.right.fill", tab: 1)
                menuButton(title: "Map", systemImage: "creditcard.fill", tab: 2)
                menuButton(title: "Settings", systemImage: "gearshape.fill", tab: 3)
                menuButton(title: "Stock", systemImage: "chart.bar.fill", tab: 4)
            }
            .padding(.horizontal)
            Spacer()
            // Logout
            Button(action: {
                NotificationCenter.default.post(name: Notification.Name("LogoutTapped"), object: nil)
                withAnimation { showMenu = false }
            }) {
                HStack {
                    Image(systemName: "arrow.turn.up.left")
                    Button(action: {
                        userAuth.logout()
                    }) {
                        Text("Logout")
                    }
                }.padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .foregroundColor(.primary)
        .background(Color(UIColor.systemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(radius: 3)
    }
    // Menu item helper
    private func menuButton(title: String, systemImage: String, tab: Int) -> some View {
        Button(action: {
            withAnimation {
                router.selectedTab = tab
                if tab != 1 { router.navigationPath = NavigationPath() }
                showMenu = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: systemImage).frame(width: 28)
                Text(title).font(.system(size: 16, weight: .medium))
                Spacer()
                if router.selectedTab == tab {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
    }
}
// MARK: - MENU BUTTON
struct MenuButton: View {
    @Binding var showMenu: Bool
    var body: some View {
        Button(action: { withAnimation { showMenu.toggle() } }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}
// SIDEMENU----------
class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    private var locationCaptured = false
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        if loc.horizontalAccuracy < 0 || loc.horizontalAccuracy > 100 {
            return
        }
        if locationCaptured { return }
        locationCaptured = true
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        let shortLat = Double(String(format: "%.6f", latitude))!
        let shortLong = Double(String(format: "%.6f", longitude))!
        print("📍 Final Accurate LAT: \(shortLat)")
        print("📍 Final Accurate LONG: \(shortLong)")
        KeychainHelper.shared.save("\(shortLat)", forKey: "saved_latitude")
        KeychainHelper.shared.save("\(shortLong)", forKey: "saved_longitude")
        manager.stopUpdatingLocation()
    }
}
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        Messaging.messaging().delegate = self
        CLLocationManager().requestWhenInUseAuthorization()
        return true
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler(.newData)
    }
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("UserInfo:", userInfo)
        completionHandler([.banner, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("UserInfo:", userInfo)
        let route = "ChatView"
        let senderId = Int(userInfo["senderId"] as? String ?? "") ?? 0
        let chatId = Int(userInfo["chatId"] as? String ?? "") ?? 0
        let receiverId = Int(userInfo["receiverId"] as? String ?? "") ?? 0
        let userImg = userInfo["userImg"] as? String ?? ""
        let userName =  ""
        if route == "ChatView" {
            NotificationCenter.default.post(name: .navigateToRoute, object: nil, userInfo: [
                "route": route,
                "senderId": receiverId,
                "chatId": chatId,
                "receiverId": senderId,
                "userImg": userImg,
                "userName":userName
            ])
        }
        completionHandler()
    }
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let token = fcmToken {
            KeychainHelper.shared.save(token, forKey: "device_token")
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": token])
            // TODO: Send token to app server if needed
        }
    }
}
extension Notification.Name {
    static let navigateToRoute = Notification.Name("navigateToRoute")
}

