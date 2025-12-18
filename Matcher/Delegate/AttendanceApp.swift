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
class AppRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var navigationPath = NavigationPath()
    @Published var senderId: Int = 0
    @Published var chatId: Int = 0
    @Published var receiverId: Int = 0
    @Published var userImg: String = ""
    @Published var userName: String = ""
}

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selectedIndex) {
                HomeView()
                    .tag(0)
                SettingView()
                    .tag(1)
                ChatListView()
                    .tag(2)
                ProfileView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                UITabBar.appearance().isHidden = true
            }

            CustomTabBar(selectedIndex: $selectedIndex)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedIndex: Int

    let tabs = [
        ("Home", "home_icon"),
        ("Like", "like_icon"),
        ("Chat", "chat_icon"),
        ("Profile", "profile_icon")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Background Shape
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.black)
                .frame(height: 85)
                .shadow(color: .black.opacity(0.2), radius: 8, y: -4)
                .padding(.horizontal, 12)

            // MARK: - Tab Items
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    TabBarButton(
                        title: tabs[index].0,
                        icon: tabs[index].1,
                        isSelected: selectedIndex == index
                    ) {
                        selectedIndex = index
                    }
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.bottom, 0)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 56, height: 56)
                            .offset(y: -20)
                            .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
                            .animation(.spring(), value: isSelected)
                    }
                    
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                        .offset(y: isSelected ? -20 : 0)
                        .animation(.spring(), value: isSelected)
                }

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .yellow : .white.opacity(0.6))
                    .padding(.bottom, 10)
                    .animation(.easeOut(duration: 0.25), value: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
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

