import SwiftUI
import PhotosUI
import MapKit
struct ProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var viewModel = GetProfileModel()
    @State private var user: User?
    @State private var currentImageIndex: Int = 0
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    LinearGradient(colors: [.splashTop, .splashBottom], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    VStack {
                        header
                        if let user {
                            SwipeCard(
                                user: user,
                                maxHeight: geo.size.height * 2
                            )
                        }
                        Spacer(minLength: 10)
                    }
                }
            }
        }
        .onAppear {
            viewModel.GetProfileAPI(param: [:]) { response in
                DispatchQueue.main.async {
                    self.user = response?.data
                }
            }
        }
    }
    var header: some View {
        HStack {
            NavigationLink {
                SettingsView()
            } label: {
                Image("setting")
            }
            Spacer()
            Text("Profile").font(AppFont.manropeSemiBold(16))
            Spacer()
            HStack {
                NavigationLink {
                    EditProfileView(user: user)
                } label: {
                    Image("edit")
                    Text("Edit")
                        .font(AppFont.manropeSemiBold(16))
                        .foregroundColor(AppColors.primaryYellow)
                }
            }
        }
        .padding(.horizontal)
    }
    struct SwipeCard: View {
        let user: User
        let maxHeight: CGFloat
        @State private var currentImageIndex: Int = 0
        private let sliderHeight: CGFloat = 420
        private let autoSlideTime: TimeInterval = 3
        @State private var slideTimer: Timer?
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        bigProfile
                        profileInfo
                        habitGrid(
                            FoodPreference: user.profile?.foodPreference ?? "",
                            Smoking: user.profile?.smoking ?? "",
                            WorkShift: user.profile?.workShift ?? "",
                            Drinking: user.profile?.drinking ?? ""
                        )
                        PartyPreferencesView()
                        RoomPhotosDisplayView(photos: user.rooms?.first?.photos ?? [])
                        RoommatesNeededSection()
                        RoomShortInfoSection(
                            spaceType: user.rooms?.first?.roomType ?? "",
                            rentSplit: user.rooms?.first?.rentSplit ?? "",
                            furnishing: user.rooms?.first?.furnishType ?? "",
                            spaceFor: user.rooms?.first?.wantToLiveWith ?? ""
                        )
                        ShowAmenitiesView(user: user)
                        locationBox
                        Spacer()
                    }
                    .padding(10)
                    .background(LinearGradient(colors: [.splashTop, .splashBottom],
                                               startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                 }
                .padding(.bottom,40)
                .toolbar(.hidden, for: .tabBar)
             }
            .padding(.horizontal)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 0)
        }
        private var bigProfile: some View {
            ZStack(alignment: .bottom) {
                profileImageSlider
                imageProgressBar
                profileOverlayContent
            }
        }
        private var profileImageSlider: some View {
            ZStack {
                TabView(selection: $currentImageIndex) {
                    ForEach(Array((user.photos ?? []).enumerated()), id: \.offset) { index, photo in
                        sliderImage(photo: photo)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: sliderHeight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                )
                .onAppear { startAutoSlide() }
                .onDisappear { stopAutoSlide() }
                HStack {
                    Button(action: { previousSlide() }) {
                        Image("leftArrow")
                    }
                    .padding(.leading, 15)
                    Spacer()
                    Button(action: { nextSlide() }) {
                        Image("rightArrow")
                    }
                    .padding(.trailing, 15)
                }
                .padding(.vertical, 20)
                .frame(height: sliderHeight)
            }
        }
        private func nextSlide() {
            let count = (user.photos ?? []).count
            if count == 0 { return }
            withAnimation { currentImageIndex = (currentImageIndex + 1) % count }
        }
        private func previousSlide() {
            let count = (user.photos ?? []).count
            if count == 0 { return }
            withAnimation { currentImageIndex = (currentImageIndex - 1 + count) % count }
        }
        private func sliderImage(photo: Photo) -> some View {
            Group {
                if let file = photo.file, let url = URL(string: file) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                } else {
                    Image("girls")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(height: sliderHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        private var imageProgressBar: some View {
            VStack {
                HStack(spacing: 6) {
                    let total = CGFloat(user.photos?.count ?? 1)
                    let totalWidth: CGFloat = UIScreen.main.bounds.width - 80
                    let progressWidth = max((totalWidth - (6 * (total - 1))) / total, 15)

                    ForEach(0..<(user.photos?.count ?? 1), id: \.self) { index in
                        Rectangle()
                            .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.35))
                            .frame(width: progressWidth, height: 3)
                            .cornerRadius(2)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
                Spacer()
            }
            .frame(height: sliderHeight)
            .allowsHitTesting(false)
        }
        private var profileOverlayContent: some View {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text("\(user.firstName ?? "") \(user.lastName ?? "") 🌼")
                            .font(AppFont.manropeSemiBold(18))
                            .foregroundColor(.white)
                        Text(" \(calculateAge(user.dob ?? ""))")
                            .font(AppFont.manropeExtraBold(22))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.profile?.professionalFieldData?.title ?? "")
                            .font(AppFont.manropeMedium(14))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        Text(user.profile?.workShift ?? "Day Shift")
                            .font(AppFont.manropeMedium(13))
                            .foregroundColor(.white)
                            .frame(minWidth: 50, minHeight: 24)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                      }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        private func startAutoSlide() {
            stopAutoSlide()
            slideTimer = Timer.scheduledTimer(withTimeInterval: autoSlideTime, repeats: true) { _ in
                let count = user.photos?.count ?? 1
                if count > 1 {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        currentImageIndex = (currentImageIndex + 1) % count
                    }
                }
            }
        }
        private func stopAutoSlide() {
            slideTimer?.invalidate()
            slideTimer = nil
        }
        private var profileInfo: some View {
            VStack(spacing: 0) {
                Text(user.profile?.describeYouBest ?? "")
                    .font(AppFont.manropeExtraBold(18))
                    .padding(.top, 10)
                Text(user.profile?.aboutYourself ?? "")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                 HStack(spacing: 10) {
                    if user.profile?.describeYouBest == "working"{
                        prefChip(user.profile?.describeYouBest ?? "", imageName: "work")
                    }else{
                        prefChip(user.profile?.describeYouBest ?? "", imageName: "book")
                    }
                    if ((user.profile?.professionalField) != nil){
                         prefChip(user.profile?.professionalFieldData?.title ?? "", imageName: nil)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        private func prefChip(_ text: String, imageName: String? = nil) -> some View {
            HStack(spacing: 6) {
                if let imageName = imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                Text(text)
                    .font(AppFont.manropeMedium(14))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .cornerRadius(10)
        }
        struct habitGrid: View {
            var FoodPreference: String
            var Smoking: String
            var WorkShift: String
            var Drinking: String
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                     LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 5) {
                         Items(title: "Food", value: FoodPreference, theme: .dark)
                         Items(title: "Smoking", value: Smoking, theme: .yellow)
                         Items(title: "Shift", value: WorkShift, theme: .yellow)
                         Items(title: "Drinking", value: Drinking, theme: .dark)
                    }
                }
                .padding(.top, 10)
            }
            @ViewBuilder
            private func Items(title: String, value: String, theme: ItemsTheme) -> some View {
                VStack(spacing: 6) {
                    Text(title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black.opacity(0.7)).padding(.bottom,10)
                    Text(value.cleanDecimal())
                        .font(AppFont.manropeMedium(12))
                        .foregroundColor(theme == .yellow ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(theme == .yellow ? Color.yellow : Color.black)
                        .cornerRadius(8)
                }
            }
            enum ItemsTheme {
                case yellow, dark
            }
        }
        struct PartyPreferencesView: View {
            var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Party Preferences")
                            .font(AppFont.manropeSemiBold(18))
                            .foregroundColor(.black)
                        HStack {
                            Image("sparkles")
                            Text("Not Party Person")
                                .font(AppFont.manropeMedium(14))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 1.0, green: 0.36, blue: 0.43))
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 20)
                .padding(.bottom, 4)
            }
        }
        struct RoomPhotosDisplayView: View {
            let photos: [Photos]
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rooms Photo")
                        .font(AppFont.manropeSemiBold(18))
                        .foregroundColor(.black)
                    HStack(spacing: 5) {
                        photoBox(size: UIScreen.main.bounds.width * 0.42, index: 0)
                        VStack(spacing: 5) {
                            HStack(spacing: 5) {
                                photoBox(size: UIScreen.main.bounds.width * 0.20, index: 1)
                                photoBox(size: UIScreen.main.bounds.width * 0.20, index: 2)
                            }
                            HStack(spacing: 5) {
                                photoBox(size: UIScreen.main.bounds.width * 0.20, index: 3)
                                photoBox(size: UIScreen.main.bounds.width * 0.20, index: 4)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 4)
            }
            private func photoBox(size: CGFloat, index: Int) -> some View {
                let urlStr = index < photos.count ? photos[index].file : nil
                return ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.3),
                                style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .frame(width: size, height: size)
                    if let urlStr,
                       let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                                    .cornerRadius(14)
                            default:
                                placeholder(size)
                            }
                        }
                    } else {
                        placeholder(size)
                    }
                }
            }
            private func placeholder(_ size: CGFloat) -> some View {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: size, height: size)
            }
        }
        struct RoommatesNeededSection: View {
            let roommatesImages: [String] = [
                "girls",
                "girls",
                "girls"
            ]
            let numberOfRoommates: Int = 3
            let onlyForFemale: Bool = true
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("\(numberOfRoommates) Roommates Needed")
                            .font(AppFont.manropeSemiBold(14))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()
                        if onlyForFemale {
                            HStack(spacing: 6) {
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 12, height: 12)
                                        )
                                Text("Only For Female")
                                    .font(AppFont.manropeSemiBold(10))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                        }
                    }
                    HStack(spacing: -15) {
                        ForEach(0..<min(roommatesImages.count, 3), id: \.self) { index in
                            Image(roommatesImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .zIndex(Double(roommatesImages.count - index))
                        }
                        Text("\(numberOfRoommates)")
                            .font(AppFont.manropeSemiBold(14))
                            .frame(width: 40, height: 40)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.8), lineWidth: 1)
                            )
                            .padding(.leading, 20)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.white, radius: 5, x: 0, y: 1)
            }
        }
        struct RoomShortInfoSection: View {
            var spaceType: String
            var rentSplit: String
            var furnishing: String
            var spaceFor: String
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Room Short Info")
                        .font(AppFont.manropeSemiBold(18))
                        .foregroundColor(.black)
                     LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 5) {
                        pillItem(title: "Space Type", value: spaceType, theme: .dark)
                        pillItem(title: "Rent Split", value: rentSplit, theme: .yellow)
                        pillItem(title: "Furnishing", value: furnishing, theme: .yellow)
                        pillItem(title: "Space For", value: spaceFor, theme: .dark)
                    }
                }
                .padding(.top, 10)
            }
            @ViewBuilder
            private func pillItem(title: String, value: String, theme: PillTheme) -> some View {
                VStack(spacing: 6) {
                    Text(title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black.opacity(0.7)).padding(.bottom,10)
                    Text(value.cleanDecimal())
                        .font(AppFont.manropeMedium(12))
                        .foregroundColor(theme == .yellow ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(theme == .yellow ? Color.yellow : Color.black)
                        .cornerRadius(8)
                }
            }
            enum PillTheme {
                case yellow, dark
            }
        }
        struct ShowAmenitiesView: View {
            var user: User
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Facilities")
                        .font(AppFont.manropeSemiBold(18))
                        .foregroundColor(.black)
                    ScrollView {
                        if let amenities = user.rooms?.first?.amenities, !amenities.isEmpty {
                            FlowLayout(spacing: 10) {
                                ForEach(amenities) { item in
                                    AmenityItem(item)
                                }
                            }
                            .padding(.top, 5)
                            .padding(.horizontal)
                        } else {
                            Text("No amenities available")
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            private func AmenityItem(_ item: Amenity) -> some View {
                HStack(spacing: 8) {
                    if let url = URL(string: item.icon ?? "") {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 18, height: 18)
                    }
                    Text(item.title ?? "")
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.03))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                )
            }
        }
        private var locationBox: some View {
            HStack {
                Text("Location :")
                    .font(AppFont.manropeExtraBold(14))
                    .foregroundColor(.black)
                    .padding(.leading,5)
                Text("\(user.rooms?.first?.location ?? "")")
                    .font(AppFont.manropeMedium(13))
                    .foregroundColor(.black)
                Spacer()
                Image("vack")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(5)
            .background(AppColors.primaryYellow)
            .cornerRadius(12)
        }
        private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Image(icon)
            }
        }
    }
}
