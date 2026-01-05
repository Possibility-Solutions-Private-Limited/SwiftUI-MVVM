import SwiftUI
import MapKit
struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TappableMapView
        init(parent: TappableMapView) {
            self.parent = parent
        }
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            parent.selectedCoordinate = coord
            withAnimation(.easeInOut(duration: 0.5)) {
                parent.region.center = coord
                parent.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
            KeychainHelper.shared.save("\(coord.latitude)", forKey: "saved_latitude")
            KeychainHelper.shared.save("\(coord.longitude)", forKey: "saved_longitude")
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        uiView.addAnnotation(annotation)
        uiView.setRegion(region, animated: true)
    }
}
struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var router: AppRouter
    @State private var showNotifications = false
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var activeIndex: Int = 0
    let profiles: [Profiles]
    init(profiles: [Profiles]) {
        self.profiles = profiles
        let savedLat = Double(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "") ?? 28.6139
        let savedLong = Double(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "") ?? 77.2090
        let coord = CLLocationCoordinate2D(latitude: savedLat, longitude: savedLong)
        _region = State(initialValue: MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        _selectedCoordinate = State(initialValue: coord)
    }
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.splashTop, .splashBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            ZStack(alignment: .top) {
                TappableMapView(region: $region, selectedCoordinate: $selectedCoordinate)
                    .ignoresSafeArea()
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
                    .font(.system(size: 16, weight: .semibold))
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
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                Text("Search Location").foregroundColor(.gray)
                Spacer()
            }
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


