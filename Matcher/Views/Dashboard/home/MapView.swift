import SwiftUI
import MapKit
import CoreLocation
struct ProfileAnnotation: Identifiable {
    let id: Int
    let profile: Profiles
    let coordinate: CLLocationCoordinate2D
}
struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var router: AppRouter
    @State private var showNotifications = false
    @State private var activeIndex: Int = 0
    @State private var mapPosition: MapCameraPosition
    @StateObject private var locationManager = LocationPermissionManager()
    @State private var hasCenteredOnUser = false
    let profiles: [Profiles]
    let annotations: [ProfileAnnotation]
    init(profiles: [Profiles]) {
        self.profiles = profiles
        let lat = Double(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "") ?? 28.6139
        let long = Double(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "") ?? 77.2090
        let defaultCoord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        _mapPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: defaultCoord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        ))
        self.annotations = profiles.enumerated().compactMap { index, profile in
            guard
                let latStr = profile.lat,
                let longStr = profile.long,
                let lat = Double(latStr),
                let long = Double(longStr)
            else { return nil }

            return ProfileAnnotation(
                id: index,
                profile: profile,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)
            )
        }
    }
    private func zoom(to coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.6)) {
            mapPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
    var body: some View {
        ZStack {
            LinearGradient(colors: [.splashTop, .splashBottom],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            ZStack(alignment: .top) {
                Map(position: $mapPosition, interactionModes: .all) {
                    UserAnnotation()
                    ForEach(annotations) { item in
                        Annotation("", coordinate: item.coordinate) {
                            pinView(item)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .ignoresSafeArea()
                .onReceive(locationManager.$userLocation) { location in
                    guard let loc = location, !hasCenteredOnUser else { return }
                    hasCenteredOnUser = true
                    zoom(to: loc.coordinate)
                }
                VStack(spacing: 12) {
                    header
                    searchBar
                }
                .padding(.top, 10)
                VStack {
                    Spacer()
                    bottomProfileCards
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { router.isTabBarHidden = true }
        .onDisappear { router.isTabBarHidden = false }
    }
    private func pinView(_ item: ProfileAnnotation) -> some View {
        Button {
            activeIndex = item.id
        } label: {
            VStack(spacing: 4) {
                if activeIndex == item.id {
                    VStack(spacing: 0) {
                        Text(item.profile.first_name ?? "")
                            .font(AppFont.manropeMedium(11))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .cornerRadius(10)
                        Triangle()
                            .fill(Color.yellow)
                            .frame(width: 12, height: 6)
                    }
                }
                if let photo = item.profile.photos?.first,
                   let urlStr = photo.file,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            activeIndex == item.id ? .yellow : .white,
                            lineWidth: 3
                        )
                    )
                    .shadow(radius: 4)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 42, height: 42)
                }
            }
        }
    }
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
            return path
        }
    }
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "chevron.left").foregroundColor(.black))
            }

            Spacer()
            HStack(spacing: 6) {
                Image("location")
                Text(KeychainHelper.shared.get(forKey: "address") ?? "")
                    .font(AppFont.manropeMedium(13))
                    .foregroundColor(.black)
            }
            Spacer()
            Button { showNotifications = true } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search Location")
                Spacer()
            }
            .foregroundColor(.gray)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "map").foregroundColor(.black))
        }
        .padding(.horizontal)
    }
    private var bottomProfileCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(profiles.indices, id: \.self) { index in
                    ProfileCardView(profile: profiles[index], isActive: index == activeIndex)
                        .onTapGesture { activeIndex = index }
                }
            }
            .padding(.horizontal)
        }
    }
    struct ProfileCardView: View {
        let profile: Profiles
        let isActive: Bool
        var body: some View {
            HStack(spacing: 8) {
                if let firstPhoto = profile.photos?.first, let urlStr = firstPhoto.file, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 130, height: 180)
                    .clipped()
                    .cornerRadius(10)
                } else {
                    Color.gray.opacity(0.2)
                        .frame(width: 130, height: 180)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(profile.first_name ?? "") \(profile.last_name ?? "")")
                        .font(AppFont.manropeBold(16))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    HStack(spacing: 0) {
                        Text("Field:")
                            .font(AppFont.manropeSemiBold(11))
                            .foregroundColor(.black)
                        Text(profile.profile?.professional_field_data?.title ?? "")
                            .font(AppFont.manropeSemiBold(11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    HStack(spacing: 0) {
                        Text("Space Type:")
                            .font(AppFont.manropeSemiBold(11))
                            .foregroundColor(.black)
                        Text("\(profile.rooms?.first?.roomType ?? "")")
                            .font(AppFont.manropeSemiBold(11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    if let roomPhotos = profile.rooms?.first?.photos {
                        RoomPhotosDisplayView(photos: roomPhotos)
                            .frame(height: 70)
                    }
                    HStack {
                        Spacer()
                        Text("₹\(profile.rooms?.first?.rentSplit ?? "")")
                            .font(AppFont.manropeMedium(11))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 72, height: 200)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }
    struct RoomPhotosDisplayView: View {
        let photos: [Photos]
        var body: some View {
            HStack(spacing: 5) {
                photoBox(index: 0, width: 70, height: 70)
                VStack(spacing: 5) {
                    HStack(spacing: 5) {
                        photoBox(index: 1, width: 30, height: 30)
                        photoBox(index: 2, width: 30, height: 30)
                    }
                    HStack(spacing: 5) {
                        photoBox(index: 3, width: 30, height: 30)
                        photoBox(index: 4, width: 30, height: 30)
                    }
                }
            }
        }
        private func photoBox(index: Int, width: CGFloat, height: CGFloat) -> some View {
            let urlStr = index < photos.count ? photos[index].file : nil
            return ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .frame(width: width, height: height)
                if let urlStr, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        default:
                            placeholder(width: width, height: height)
                        }
                    }
                } else {
                    placeholder(width: width, height: height)
                }
            }
        }
        private func placeholder(width: CGFloat, height: CGFloat) -> some View {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.15))
                .frame(width: width, height: height)
        }
    }
}
