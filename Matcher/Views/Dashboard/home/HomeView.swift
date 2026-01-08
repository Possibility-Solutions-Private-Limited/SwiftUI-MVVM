import SwiftUI
import PhotosUI
import MapKit
struct Card: Identifiable {
    let id = UUID()
    let step: Int
}
struct HomeView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var cards: [Card] = []
    @State private var totalSteps: Int = 8
    @State private var showFinalStep = 0
    @StateObject private var viewModel = BasicModel()
    @StateObject private var selections = UserSelections()
    @StateObject var dashboardView = DashboardViewModel()
    @State private var profiles: [Profiles] = []
    private let initialCards: [Card] = [
        Card(step: 7),
        Card(step: 6),
        Card(step: 5),
        Card(step: 4),
        Card(step: 3),
        Card(step: 2),
        Card(step: 1),
        Card(step: 0)
    ]
    //filter=============
    @State private var showFilters = false
    @State private var savedFilters: FiltersData? = nil
    @State private var genderId: Int = 0
    @State private var age: Double = 50
    @State private var foodChoice: String = ""
    @State private var partyPreference: Int = 0
    @State private var smoke: String = ""
    @State private var drink: String = ""
    @State private var distanceMin: Double = 0
    @State private var distanceMax: Double = 100
    @Binding var currentPage: Int
    @State private var showNotifications = false
    //========
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    LinearGradient(
                        colors: [.splashTop, .splashBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    VStack {
                        if userAuth.steps {
                            if userAuth.space {
                                header
                                Text("Nearby Rooms & Roommates")
                                    .font(AppFont.manropeExtraBold(18))
                                searchBar
                                ZStack {
                                    if profiles.isEmpty {
                                        NoRoomsView()
                                    }else{
                                        ForEach(profiles.indices.reversed(), id: \.self) { index in
                                            let profile = profiles[index]
                                            SwipeCard(
                                                profiles: profile,
                                                maxHeight: geo.size.height * 2,
                                                isActive: index == 0
                                            ) {
                                                removeProfile(profile)
                                            }
                                            .id(profile.id)
                                            .zIndex(Double(profiles.count - index))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }else{
                                SpaceView(
                                    showFinalStep: $showFinalStep,
                                    viewModel: viewModel,
                                    selections: selections,
                                    onNext: next
                                )
                            }
                        }else{
                            if showFinalStep == 1 {
                                FinalStepView(
                                    showFinalStep: $showFinalStep,
                                    viewModel: viewModel,
                                    selections: selections,
                                    onNext: next
                                )
                            } else if showFinalStep == 2 {
                                GenderStepView(
                                    showFinalStep: $showFinalStep,
                                    viewModel: viewModel,
                                    selections: selections,
                                    onNext: next
                                )
                            } else if showFinalStep == 3 {
                                SpaceView(
                                    showFinalStep: $showFinalStep,
                                    viewModel: viewModel,
                                    selections: selections,
                                    onNext: next
                                )
                            } else {
                                header
                                title
                                ZStack {
                                    ForEach(cards) { card in
                                        let index = cards.firstIndex { $0.id == card.id } ?? 0
                                        ProfileSwipeCard(
                                            viewModel: viewModel,
                                            selections: selections,
                                            step: card.step,
                                            currentStep: displayStep(for: card.step),
                                            totalSteps: totalSteps,
                                            maxHeight: geo.size.height * 0.7
                                        ) {
                                            withAnimation(.spring()) {
                                                cards.removeAll { $0.id == card.id }
                                                if cards.isEmpty {
                                                    showFinalStep = 1
                                                }
                                            }
                                        }
                                        .offset(y: CGFloat(index) * 7)
                                    }
                                }
                                .padding(.horizontal)
                                Spacer(minLength: 5)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchBasicData(param: [
                "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
                "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
                ]) {
                if userAuth.steps && userAuth.space {
                    loadSavedFilters()
                    loadDashboardAPI()
                }
            }
            if !userAuth.steps   && !userAuth.space{
                cards = initialCards
            }
        }
        .onReceive(dashboardView.$profiles) { newProfiles in
            profiles = newProfiles
        }
        .onChange(of: selections.selectedRole) {
            rebuildCards()
        }
        .onChange(of: userAuth.space) {
            loadSavedFilters()
            loadDashboardAPI()
        }
    }
    private func loadDashboardAPI() {
        dashboardView.loadDashboard(params: [
            "page": currentPage,   
            "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
            "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
            "age": Int(age),
            "distance": Int(distanceMax),
            "want_to_live_with": Int(genderId),
            "food_preference": foodChoice.lowercased(),
            "party_preference": Int(partyPreference),
            "smoking": smoke.lowercased(),
            "drinking": drink.lowercased()
        ])
    }
    func loadSavedFilters() {
        guard let saved = UserDefaults.standard.data(forKey: "SavedFilters"),
              let decoded = try? JSONDecoder().decode(FiltersData.self, from: saved)
        else {
            genderId = viewModel.genders.first?.id ?? 0
            foodChoice = "Veg"
            partyPreference = viewModel.partyPreferences.first?.id ?? 0
            smoke = "Yes"
            drink = "Yes"
            return
        }
        genderId = decoded.genderId
        age = Double(decoded.age)
        foodChoice = decoded.foodChoice
        partyPreference = decoded.partyPreference
        smoke = decoded.smoke
        drink = decoded.drink
        distanceMin = Double(decoded.distanceMin)
        distanceMax = Double(decoded.distanceMax)
    }
    struct NoRoomsView: View {
        var body: some View {
            VStack(spacing: 0) {
                Image("no_room")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("No Rooms Available Yet")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(.black)
                Text("Try changing location or preferences")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.bottom, 90)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .tabBar)
        }
    }
    // main CARD======
    struct SwipeCard: View {
        let profiles: Profiles
        let maxHeight: CGFloat
        let isActive: Bool
        let onRemove: () -> Void
        @State private var currentImageIndex: Int = 0
        private let sliderHeight: CGFloat = 420
        private let autoSlideTime: TimeInterval = 3
        @State private var offset: CGSize = .zero
        @State private var rotation: Double = 0
        @StateObject private var like = likesModel()
        @StateObject private var dislike = DislikesModel()
        @State private var slideTimer: Timer?
        private func swipeLeft() {
            withAnimation(.interpolatingSpring(stiffness: 35, damping: 18)) {
                offset = CGSize(width: -500, height: 0)
                rotation = -18
            }
            dislike.SwipeDislikeAPI(type: "dislike",userId:profiles.profile?.user_id ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onRemove() }
        }
        private func swipeRight() {
            withAnimation(.interpolatingSpring(stiffness: 35, damping: 18)) {
                offset = CGSize(width: 500, height: 0)
                rotation = 18
            }
            like.SwipeLikeAPI(type: "like",userId:profiles.profile?.user_id ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onRemove() }
        }
        private var cardSwipeGesture: some Gesture {
            DragGesture()
                .onChanged { gesture in
                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                    }
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                        if gesture.translation.width > 120 {
                            swipeRight()
                        } else if gesture.translation.width < -120 {
                            swipeLeft()
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                                rotation = 0
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                     }
                }
            }
        }
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        bigProfile
                        profileInfo
                        habitGrid(
                            FoodPreference: profiles.profile?.food_preference ?? "",
                            Smoking: profiles.profile?.smoking ?? "",
                            WorkShift: profiles.profile?.work_shift ?? "",
                            Drinking: profiles.profile?.drinking ?? ""
                        )
                        PartyPreferencesView(party:profiles.profile?.into_parties_data?.title ?? "")
                        RoomPhotosDisplayView(photos: profiles.rooms?.first?.photos ?? [])
                        RoommatesNeededSection()
                        RoomShortInfoSection(
                            spaceType: profiles.rooms?.first?.roomType ?? "",
                            rentSplit: profiles.rooms?.first?.rentSplit ?? "",
                            furnishing: profiles.rooms?.first?.furnishType ?? "",
                            spaceFor: profiles.rooms?.first?.wantToLiveWith ?? ""
                        )
                        ShowAmenitiesView(profiles: profiles)
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
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 0)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .contentShape(Rectangle())
            .gesture(cardSwipeGesture, including: .gesture)
        }
        private var bigProfile: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $currentImageIndex) {
                    ForEach(Array((profiles.photos ?? []).enumerated()), id: \.offset) { index, photo in
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
                .task(id: isActive) {
                    if isActive {
                        stopAutoSlide()
                        currentImageIndex = 0
                        startAutoSlide()
                    } else {
                        stopAutoSlide()
                    }
                }
                .allowsHitTesting(false)
                VStack {
                    HStack(spacing: 6) {
                        let count = CGFloat(profiles.photos?.count ?? 1)
                        let totalWidth: CGFloat = UIScreen.main.bounds.width - 80
                        let progressWidth = max((totalWidth - (6 * (count - 1))) / count, 15)
                        ForEach(0..<(profiles.photos?.count ?? 1), id: \.self) { index in
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
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text("\(profiles.first_name ?? "") \(profiles.last_name ?? "") 🌼")
                                .font(AppFont.manropeSemiBold(18))
                                .foregroundColor(.white)
                            Text(" \(calculateAge(profiles.dob ?? ""))")
                                .font(AppFont.manropeExtraBold(22))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profiles.profile?.professional_field_data?.title ?? "")
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            Text(profiles.profile?.work_shift ?? "Day Shift")
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
                    VStack(spacing: 10) {
                        circleButton(icon: "cross") { swipeLeft() }
                        circleButton(icon: "dil") { swipeRight() }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        private func startAutoSlide() {
            guard slideTimer == nil else { return }
            slideTimer = Timer.scheduledTimer(withTimeInterval: autoSlideTime, repeats: true) { _ in
                let count = profiles.photos?.count ?? 1
                guard count > 1 else { return }
                withAnimation(.easeInOut(duration: 0.8)) {
                    currentImageIndex = (currentImageIndex + 1) % count
                }
            }
        }
        private func stopAutoSlide() {
            slideTimer?.invalidate()
            slideTimer = nil
        }
        private var profileInfo: some View {
            VStack(spacing: 0) {
                Text(profiles.profile?.describe_you_best ?? "")
                    .font(AppFont.manropeExtraBold(18))
                    .padding(.top, 10)
                Text(profiles.profile?.about_yourself ?? "")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                 HStack(spacing: 10) {
                    if profiles.profile?.describe_you_best == "working"{
                        prefChip(profiles.profile?.describe_you_best ?? "", imageName: "work")
                    }else{
                        prefChip(profiles.profile?.describe_you_best ?? "", imageName: "book")
                    }
                     if ((profiles.profile?.professional_field) != nil){
                         prefChip(profiles.profile?.professional_field_data?.title ?? "", imageName: nil)
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
            var party: String
            var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Party Preferences")
                            .font(AppFont.manropeSemiBold(18))
                            .foregroundColor(.black)
                        HStack {
                            Image("sparkles")
                            Text(party)
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
            var profiles: Profiles
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Facilities")
                        .font(AppFont.manropeSemiBold(18))
                        .foregroundColor(.black)
                    ScrollView {
                        if let amenities = profiles.rooms?.first?.amenities, !amenities.isEmpty {
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
                Text("\(profiles.rooms?.first?.location ?? "")")
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
    private func removeProfile(_ profile: Profiles) {
        withAnimation(.spring()) {
            profiles.removeAll { $0.id == profile.id }
            if profiles.isEmpty {
                loadSavedFilters()
                loadDashboardAPI()
            }
        }
    }
    struct FiltersData: Codable {
        let genderId: Int
        let age: Int
        let foodChoice: String
        let partyPreference: Int
        let smoke: String
        let drink: String
        let distanceMin: Int
        let distanceMax: Int
    }
    struct FiltersSheetView: View {
        @ObservedObject var viewModel: BasicModel
        @Environment(\.dismiss) private var dismiss
        @State private var genderId:Int = 0
        @State private var age: Double = 50
        @State private var foodChoice: String = ""
        @State private var partyPreference:Int = 0
        @State private var smoke: String = ""
        @State private var drink: String = ""
        @State private var distanceMin: Double = 0
        @State private var distanceMax: Double = 100
        let onApply: (FiltersData) -> Void
        private var options: [OptionItem] {
            viewModel.genders
        }
        private var fields: [OptionItem] {
            viewModel.partyPreferences
        }
        init(viewModel: BasicModel, onApply: @escaping (FiltersData) -> Void) {
          self.viewModel = viewModel
          self.onApply = onApply
          UISlider.appearance().thumbTintColor = UIColor(AppColors.primaryYellow)
        }
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Filters")
                        .font(AppFont.manropeBold(22))
                        .foregroundColor(AppColors.Black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    Text("Who Would You Like To Live With?")
                        .font(AppFont.manropeBold(14))
                    HStack {
                        FlowLayout(spacing: 10) {
                            ForEach(options) { field in
                                genderButton(field)
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Age")
                                .font(AppFont.manropeBold(14))
                            Spacer()
                            Text("\(Int(age))")
                                .font(AppFont.manropeSemiBold(14))
                                .foregroundColor(AppColors.primaryYellow)
                        }
                        Slider(value: $age, in: 18...60)
                            .tint(AppColors.primaryYellow)
                    }
                    Text("Food Choice")
                        .font(AppFont.manropeBold(14))
                    HStack(spacing: 0) {
                        foodButton("Veg")
                        foodButton("Non-Veg")
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.borderGray, lineWidth: 1)
                    )
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Distance")
                                .font(AppFont.manropeBold(14))
                            Spacer()
                            Text("\(Int(distanceMin)) - \(Int(distanceMax)) Km")
                                .font(AppFont.manropeSemiBold(14))
                                .foregroundColor(AppColors.primaryYellow)
                        }
                        HStack {
                            RangeSlider(minValue: $distanceMin, maxValue: $distanceMax, range: 0...1000)
                        }.padding()
                    }
                    Text("Party Preferences")
                        .font(AppFont.manropeBold(14))
                    HStack {
                        FlowLayout(spacing: 10) {
                            ForEach(fields) { field in
                                PartyButton(field)
                            }
                        }
                    }
                    Text("Smoking")
                        .font(AppFont.manropeBold(14))
                    HStack(spacing: 0) {
                        yesNoButton("Yes", selected: $smoke)
                        yesNoButton("No", selected: $smoke)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.borderGray, lineWidth: 1)
                    )
                    Text("Drinking")
                        .font(AppFont.manropeBold(14))
                    HStack(spacing: 0) {
                        yesNoButton("Yes", selected: $drink)
                        yesNoButton("No", selected: $drink)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.borderGray, lineWidth: 1)
                    )
                    Spacer()
                    Button(action: applyFilters) {
                        Text("Apply Filters")
                            .font(AppFont.manropeBold(16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.Black)
                            .cornerRadius(10)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear { loadSavedFilters() }
        }
        func applyFilters() {
            let data = FiltersData(
                genderId: Int(genderId),
                age: Int(age),
                foodChoice: foodChoice,
                partyPreference: partyPreference,
                smoke: smoke,
                drink: drink,
                distanceMin: Int(distanceMin),
                distanceMax: Int(distanceMax)
            )
            onApply(data)
            if let encoded = try? JSONEncoder().encode(data) {
                UserDefaults.standard.set(encoded, forKey: "SavedFilters")
            }
            dismiss()
        }
        func loadSavedFilters() {
            guard let saved = UserDefaults.standard.data(forKey: "SavedFilters"),
                  let decoded = try? JSONDecoder().decode(FiltersData.self, from: saved)
            else {
                genderId = viewModel.genders.first?.id ?? 0
                foodChoice = "Veg"
                partyPreference = viewModel.partyPreferences.first?.id ?? 0
                smoke = "Yes"
                drink = "Yes"
                return
            }
            genderId = decoded.genderId
            age = Double(decoded.age)
            foodChoice = decoded.foodChoice
            partyPreference = decoded.partyPreference
            smoke = decoded.smoke
            drink = decoded.drink
            distanceMin = Double(decoded.distanceMin)
            distanceMax = Double(decoded.distanceMax)
        }
        func genderButton(_ field: OptionItem) -> some View {
            Button {
                genderId = field.id
            } label: {
                Text(field.title)
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(genderId == field.id ? .black : .white)
                    .padding()
                    .background(genderId == field.id ? AppColors.primaryYellow : AppColors.Black)
                    .cornerRadius(8)
            }
        }
        func foodButton(_ title: String) -> some View {
            Button {
                foodChoice = title
            } label: {
                Text(title)
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(foodChoice == title ? .black : .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(foodChoice == title ? AppColors.primaryYellow : AppColors.Black)
            }
        }
        private func PartyButton(_ field: OptionItem) -> some View {
            Button {
                partyPreference = field.id
            } label: {
                Text(field.title)
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(partyPreference == field.id ? .black : .white)
                    .padding()
                    .background(partyPreference == field.id ? AppColors.primaryYellow : AppColors.Black)
                    .cornerRadius(8)
            }
        }
        func yesNoButton(_ title: String, selected: Binding<String>) -> some View {
            Button {
                selected.wrappedValue = title
            } label: {
                Text(title)
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(selected.wrappedValue == title ? .black : .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selected.wrappedValue == title ? AppColors.primaryYellow : AppColors.Black)
            }
        }
    }
    private func next() {}
    private func rebuildCards() {
        if selections.selectedRole == "Student" {
            let filtered = initialCards.filter { $0.step != 1 }
            cards = filtered
            totalSteps = filtered.count
        } else {
            cards = initialCards
            totalSteps = initialCards.count
        }
    }
    private func displayStep(for step: Int) -> Int {
        let visibleSteps = cards.map(\.step).sorted()
        return (visibleSteps.firstIndex(of: step) ?? 0) + 1
    }
    var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3)
                            )

                    } else if phase.error != nil {
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                if let savedAddress = KeychainHelper.shared.get(forKey: "address") {
                    Text(savedAddress).font(AppFont.manropeSemiBold(16))
                }
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
    var searchBar: some View {
        HStack(spacing: 5) {
                HStack(spacing: 5) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Perfect Room Starts Here")
                            .font(AppFont.manropeSemiBold(15))
                            .foregroundColor(.black)
                        Text("Discover Your Next Room & Roommate")
                            .font(AppFont.manrope(11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        showFilters.toggle()
                    } label: {
                    Image("slider")
                    }
                    .sheet(isPresented: $showFilters) {
                        FiltersSheetView(viewModel: viewModel) { filter in
                            dashboardView.loadDashboard(params: [
                                "page": currentPage,
                                "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
                                "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
                                "age":Int(filter.age),
                                "distance":Int(filter.distanceMax),
                                "want_to_live_with": Int(filter.genderId),
                                "food_preference": filter.foodChoice.lowercased(),
                                "party_preference": Int(filter.partyPreference),
                                "smoking": filter.smoke.lowercased(),
                                "drinking": filter.drink.lowercased()
                            ])
                        }
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                    }
                }
                .frame(height: 40)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                   RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
                NavigationLink {
                    MapView(profiles: profiles)
                } label: {
                    Image("map")
             }
         }
        .padding(.horizontal, 20)
        .padding(.bottom,5)
    }
    var title: some View {
        VStack(spacing: 5) {
            Text("Let’s match your lifestyle with the right people")
                .font(AppFont.manropeBold(17))
                .multilineTextAlignment(.center)
            Text("Share your lifestyle so others can instantly get your vibe.")
                .multilineTextAlignment(.center)
                .font(AppFont.manrope(14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.leading,2)
        .padding(.trailing,2)
    }
    struct ProfileSwipeCard: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        let step: Int
        let currentStep: Int
        let totalSteps: Int
        let maxHeight: CGFloat
        let onRemove: () -> Void
        @State private var offset: CGSize = .zero
        @State private var rotation: Double = 0
        private func swipe() {
            withAnimation(.interpolatingSpring(
                stiffness: 35,
                damping: 18
            )) {
                offset = CGSize(width: 500, height: 0)
                rotation = 18
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                onRemove()
            }
        }
        var body: some View {
            VStack {
                switch step {
                case 0:
                    StepOneView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 1:
                    if selections.selectedRole != "Student" {
                        StepTwoView(
                            viewModel: viewModel,
                            selections: selections,
                            currentStep: currentStep,
                            totalSteps: totalSteps,
                            onNext: swipe,
                            maxHeight: maxHeight)
                    }
                case 2:
                    StepThreeView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 3:
                    StepFourView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 4:
                    StepFiveView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 5:
                    StepSixView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 6:
                    StepSevenView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 7:
                    StepEightView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                default:
                    StepOneView(
                        viewModel: viewModel,
                        selections: selections,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged {
                        offset = $0.translation
                        rotation = Double($0.translation.width / 20)
                    }
                    .onEnded {
                        if abs($0.translation.width) > 120 {
                            swipe()
                        } else {
                         withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
            )
        }
    }
}
struct StepOneView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    var body: some View {
        VStack(spacing: 24) {
            Text("What best describes you?")
                .font(AppFont.manropeBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top, 40)
            HStack(spacing: 16) {
                roleCard(
                    title: "Student",
                    icon: "book"
                )
                roleCard(
                    title: "Working",
                    icon: "work"
                )
            }
            Spacer()
            nextButton
        }
        .padding(20)
        .frame(minHeight: maxHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
    }
    func roleCard(title: String, icon: String) -> some View {
        Button {
            selections.selectedRole = title
        } label: {
            VStack(spacing: 14) {
                Image(icon)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(AppColors.Black)

                Text(title)
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(AppColors.Black)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selections.selectedRole == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
              )
        }
    }
    var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedRole.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selections.selectedRole.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepTwoView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    private var fields: [OptionItem] {
        viewModel.professionalFields
    }
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    Text("What’s Your Professional Field?")
                        .font(AppFont.manropeBold(16))
                        .padding(.top, 50)
                    FlowLayout(spacing: 10) {
                        ForEach(fields) { field in
                            CategoryButton(field)
                        }
                    }
                }
                .padding(.horizontal)
            }
            nextButton
                .padding(.horizontal)
                .padding(.vertical, 20)
        }
        .frame(maxHeight: maxHeight)
    }
    private func CategoryButton(_ field: OptionItem) -> some View {
        Button {
            selections.selectedCategory = field.id
        } label: {
            Text(field.title)
                .font(AppFont.manropeMedium(13))
                .foregroundColor(AppColors.Black)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    selections.selectedCategory == field.id
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.ExtralightGray, lineWidth: 1)
                )
        }
    }
    private var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedCategory == nil ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selections.selectedCategory == nil)
        .padding(.bottom, 8)
    }
}
struct StepThreeView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    var body: some View {
        VStack(spacing: 24) {
            Text("What’s your work shift?")
                .font(AppFont.manropeBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top, 40)
            HStack(spacing: 16) {
                shiftCard(title: "Day", icon: "day")
                shiftCard(title: "Night", icon: "night")
            }
            Spacer()
            nextButton
        }
        .padding(20)
        .frame(minHeight: maxHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
    }
    func shiftCard(title: String, icon: String) -> some View {
        Button {
            selections.selectedShift = title
        } label: {
            VStack(spacing: 14) {
                Image(icon)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(AppColors.Black)
                Text(title)
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(AppColors.Black)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selections.selectedShift == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
             )
        }
    }
    var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedShift.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedShift.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepFourView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    var body: some View {
        VStack(spacing: 24) {
            Text("Your Food Preference ?")
                .font(AppFont.manropeBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top, 40)
            HStack(spacing: 16) {
                foodCard(title: "Veg", icon: "veg")
                foodCard(title: "Non-Veg", icon: "nonveg")
            }
            Spacer()
            nextButton
        }
        .padding(20)
        .frame(minHeight: maxHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
    }
    func foodCard(title: String, icon: String) -> some View {
        Button {
            selections.selectedFood = title
        } label: {
            VStack(spacing: 14) {
                Image(icon)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(AppColors.Black)
                Text(title)
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(AppColors.Black)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selections.selectedFood == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedFood.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedFood.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepFiveView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    private var fields: [OptionItem] {
        viewModel.partyPreferences
    }
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Are You Into Parties?")
                        .font(AppFont.manropeBold(16))
                        .padding(.top, 50)
                    FlowLayout(spacing: 10) {
                        ForEach(fields) { field in
                            PartyButton(field)
                        }
                    }
                }
                .padding(.horizontal)
            }
            nextButton
                .padding(.horizontal)
                .padding(.vertical, 20)
        }
        .frame(maxHeight: maxHeight)
    }
    private func PartyButton(_ field: OptionItem) -> some View {
        Button {
            selections.selectedParties = field.id
        } label: {
            Text(field.title)
                .font(AppFont.manropeMedium(13))
                .foregroundColor(AppColors.Black)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    selections.selectedParties == field.id
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.ExtralightGray, lineWidth: 1)
                )
        }
    }
    private var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedParties == nil ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedParties == nil)
        .padding(.bottom, 8)
    }
}
struct StepSixView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    var body: some View {
        VStack(spacing: 24) {
            Text("Do You Smoke?")
                .font(AppFont.manropeBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top, 40)
            HStack(spacing: 16) {
                foodCard(title: "Yes", icon: "yes")
                foodCard(title: "No", icon: "no")
            }
            Spacer()
            nextButton
        }
        .padding(20)
        .frame(minHeight: maxHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
    }
    func foodCard(title: String, icon: String) -> some View {
        Button {
            selections.selectedSmoke = title
        } label: {
            VStack(spacing: 14) {
                Image(icon)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(AppColors.Black)
                Text(title)
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(AppColors.Black)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selections.selectedSmoke == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedSmoke.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedSmoke.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepSevenView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    var body: some View {
        VStack(spacing: 24) {
            Text("Do You Drink?")
                .font(AppFont.manropeBold(18))
                .foregroundColor(AppColors.Black)
                .padding(.top, 40)
            HStack(spacing: 16) {
                drinkCard(title: "Yes", icon: "drinkyes")
                drinkCard(title: "No", icon: "drinkno")
            }
            Spacer()
            nextButton
        }
        .padding(20)
        .frame(minHeight: maxHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
    }
    func drinkCard(title: String, icon: String) -> some View {
        Button {
            selections.selectedDrink = title
        } label: {
            VStack(spacing: 14) {
                Image(icon)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(AppColors.Black)
                Text(title)
                    .font(AppFont.manropeSemiBold(16))
                    .foregroundColor(AppColors.Black)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selections.selectedDrink == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedDrink.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedDrink.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepEightView: View {
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let maxHeight: CGFloat
    @State private var isFocused: Bool = false
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Share a Little About Yourself?")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(AppColors.Black)
                    .padding(.top, 32)
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .frame(height: 160)
                    if selections.selectedAbout.isEmpty {
                        Text("type here...")
                            .font(AppFont.manropeMedium(14))
                            .foregroundColor(.gray)
                            .padding(.top, 14)
                            .padding(.leading, 14)
                    }
                    MultilineTextView(text: $selections.selectedAbout, isFocused: $isFocused)
                        .frame(height: 160)
                }
                Spacer(minLength: 10)
                nextButton
            }
            .padding(20)
            .frame(minHeight: maxHeight)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            isFocused = false
        }
    }
    private var nextButton: some View {
        Button(action: {
            onNext()
        }) {
            HStack {
                Text("\(currentStep)/\(totalSteps)")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.yellow)
                Spacer()
                Text("Next")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedAbout.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
        }
        .disabled(selections.selectedAbout.isEmpty)
        .padding(.bottom, 8)
    }
}
struct FinalStepView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @Binding var showFinalStep: Int
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let onNext: () -> Void
    var body: some View {
        VStack {
            header
            Spacer().frame(height: 40)
            title
            Spacer().frame(height: 30)
            VStack(spacing: 16) {
                OptionButton(title: "Yes, I have a room to share", isSelected: selections.roomOption == "Yes") {
                    selections.roomOption = "Yes"
                }
                OptionButton(title: "No, I’m looking for a room", isSelected: selections.roomOption == "No") {
                    selections.roomOption = "No"
                }
            }
            .padding(.horizontal, 20)
             Spacer()
             nextButton
            .padding(.horizontal, 10)
            .padding(.bottom, 200)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            
        }
    }
    private var nextButton: some View {
        HStack(spacing: 12) {
            Button(action: {
                showFinalStep = 2
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            selections.roomOption.isEmpty
                            ? Color.black.opacity(0.3)
                            : Color.black
                        )
                        .frame(height: 56)
                    Text("Next")
                        .font(AppFont.manropeMedium(16))
                        .foregroundColor(.white)
                }
            }.disabled(selections.roomOption.isEmpty)

        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
    var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3)
                            )

                    } else if phase.error != nil {
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                if let savedAddress = KeychainHelper.shared.get(forKey: "address") {
                    Text(savedAddress).font(AppFont.manropeSemiBold(16))
                }
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
    var title: some View {
        VStack(spacing: 5) {
            Text("Do you have a room right now?")
                .font(AppFont.manropeBold(17))
                .multilineTextAlignment(.center)
            Text("This helps us match you with people who fit your living vibe — whether you’re offering a room or looking")
                .multilineTextAlignment(.center)
                .font(AppFont.manrope(14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.leading,2)
        .padding(.trailing,2)
    }
    struct OptionButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(isSelected ? "select" : "unselect")
                        .resizable()
                        .frame(width: 22, height: 22)
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.yellow : Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
struct GenderStepView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var STEP = StepTwoModel()
    @State private var isUploading = false
    @StateObject private var validator = ValidationHelper()
    @Binding var showFinalStep: Int
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let onNext: () -> Void
    private var options: [OptionItem] {
        viewModel.genders
    }
    var body: some View {
        VStack {
            header
            Spacer().frame(height: 40)
            title
            Spacer().frame(height: 30)
            optionsSection
            Spacer()
             nextButton
            .padding(.horizontal, 10)
            .padding(.bottom, 100)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
        }
    }
    var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3)
                            )
                    } else if phase.error != nil {
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                if let savedAddress = KeychainHelper.shared.get(forKey: "address") {
                    Text(savedAddress).font(AppFont.manropeSemiBold(16))
                }
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
    var title: some View {
        VStack(spacing: 5) {
            Text("Who Would You Like to Live With?")
                .font(AppFont.manropeBold(17))
                .multilineTextAlignment(.center)
            Text("Pick the gender you prefer to meet. You can update this anytime.")
                .multilineTextAlignment(.center)
                .font(AppFont.manrope(14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.leading,2)
        .padding(.trailing,2)
    }
    var optionsSection: some View {
        VStack(spacing: 16) {
            ForEach(options) { field in
                GenderOptionCard(field)
            }
        }
        .padding(.horizontal, 20)
    }
    private func GenderOptionCard(_ field: OptionItem) -> some View {
        Button {
            selections.genderOption = field.id
        } label: {
            HStack(spacing: 14) {
                Image(selections.genderOption == field.id ? "select" : "unselect")
                    .resizable()
                    .frame(width: 22, height: 22)

                Text(field.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                selections.genderOption == field.id
                ? AppColors.primaryYellow
                : Color.white
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    private var nextButton: some View {
        HStack(spacing: 12) {
            Button(action: {
                showFinalStep -= 1
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.primaryYellow)
                        .frame(width: 56, height: 56)
                    Image("dobleBack")
                }
            }
            Button(action: StepTwoSubmit) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            (selections.genderOption == nil || isUploading)
                            ? Color.black.opacity(0.3)
                            : Color.black
                        )
                        .frame(height: 56)
                    HStack(spacing: 12) {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                        }
                        Text("Next")
                            .font(AppFont.manropeMedium(16))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(selections.genderOption == nil || isUploading)
            .frame(maxWidth: .infinity)
            .opacity(isUploading ? 0.7 : 1)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
    func StepTwoSubmit() {
        isUploading = true
        let param: [String: Any] = [
            "describe_you_best": selections.selectedRole.lowercased(),
            "professional_field": selections.selectedCategory ?? "",
            "work_shift":selections.selectedShift.lowercased(),
            "food_preference":selections.selectedFood.lowercased(),
            "into_parties":selections.selectedParties ?? 0,
            "smoking":selections.selectedSmoke.lowercased(),
            "drinking":selections.selectedDrink.lowercased(),
            "about_yourself":selections.selectedAbout.lowercased(),
            "do_you_have_room":selections.roomOption.lowercased(),
            "want_live_with":selections.genderOption ?? 0,
        ]
        STEP.StepTwoAPI(param: param) { response in
            DispatchQueue.main.async {
                guard let response = response else {
                    validator.showValidation("Something went wrong")
                    validator.showToast = true
                    isUploading = false
                    return
                }
                guard response.success else {
                    validator.showValidation(response.message ?? "Request failed")
                    validator.showToast = true
                    isUploading = false
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    userAuth.stepsComplete()
                    validator.showValidation(response.message ?? "Success")
                    validator.showToast = true
                    isUploading = false
                    showFinalStep = 3
                }
            }
        }
    }
}
struct SpaceView: View {
    @State private var showNotifications = false
    @EnvironmentObject var userAuth: UserAuth
    @Binding var showFinalStep: Int
    @ObservedObject var viewModel: BasicModel
    @ObservedObject var selections: UserSelections
    let onNext: () -> Void
    @State private var mainImage: UIImage?
    @State private var img1: UIImage?
    @State private var img2: UIImage?
    @State private var img3: UIImage?
    @State private var img4: UIImage?
    @State private var selectedSpaceType: OptionItem?
    @State private var selectedRoommates = 1
    @State private var rent: String = "5000"
    @State private var selectedFurnishing: OptionItem?
    @State private var selectedGender: OptionItem?
    @State private var selectedAmenities: Set<Int> = []
    @StateObject private var locationManager = LocationPermissionManager()
    @State private var cameraRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.6782, longitude: -73.9442),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var mapPosition: MapCameraPosition = .automatic
    private var savedAddress: String {
        KeychainHelper.shared.get(forKey: "saved_address") ?? "Fetching location..."
    }
    @State private var selectedPhotoBig: PhotosPickerItem?
    @State private var selectedPhoto1: PhotosPickerItem?
    @State private var selectedPhoto2: PhotosPickerItem?
    @State private var selectedPhoto3: PhotosPickerItem?
    @State private var selectedPhoto4: PhotosPickerItem?
    @State private var images: [UIImage?] = Array(repeating: nil, count: 5)
    @StateObject private var validator = ValidationHelper()
    @StateObject private var ROOM = RoomModel()
    @State private var isUploading = false
    init(
        showFinalStep: Binding<Int>,
        viewModel: BasicModel,
        selections: UserSelections,
        onNext: @escaping () -> Void
    ) {
        self._showFinalStep = showFinalStep
        self.viewModel = viewModel
        self.selections = selections
        self.onNext = onNext
        
        if let first = viewModel.roomTypes.first {
            _selectedSpaceType.wrappedValue = first
        }
        if let first = viewModel.furnishTypes.first {
            _selectedFurnishing.wrappedValue = first
        }
        if let first = viewModel.genders.first {
            _selectedGender.wrappedValue = first
        }
    }
    var body: some View {
        VStack(spacing: 20) {
            header
            ScrollView(showsIndicators: false) {
                title
                VStack(alignment: .leading, spacing: 20) {
                    photosSection.padding(.top, 10)
                    sectionTitle("Space Type")
                    SegmentedView(options:  viewModel.roomTypes, selected: $selectedSpaceType)
                    sectionTitle("How Many Roommates Do You Want?")
                    roommatesSection
                    sectionTitle("Rent Split (Per Person)")
                    rentField
                    sectionTitle("Furnishing")
                    SegmentedView(options:  viewModel.furnishTypes, selected: $selectedFurnishing)
                    sectionTitle("Amenities")
                    StepAmenitiesView(
                        viewModel: viewModel,
                        selectedAmenities: $selectedAmenities
                    )
                    sectionTitle("Who Would You Like To Live With?")
                    SegmentedView(options: viewModel.genders, selected: $selectedGender)
                    mapSection
                    nextButton
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 68)
            .ignoresSafeArea(.container, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
        }
        .onReceive(viewModel.$roomTypes) { list in
            if selectedSpaceType == nil, let first = list.first {
                selectedSpaceType = first
            }
        }
        .onReceive(viewModel.$furnishTypes) { list in
            if selectedFurnishing == nil, let first = list.first {
                selectedFurnishing = first
            }
        }
        .onReceive(viewModel.$genders) { list in
            if selectedGender == nil, let first = list.first {
                selectedGender = first
            }
        }
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
        .onChange(of: locationManager.latitude) { _, _ in
            updateCamera()
        }
    }
    private func updateCamera() {
        let lat = locationManager.latitude
        let lon = locationManager.longitude
        guard lat != 0, lon != 0 else { return }
        mapPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Add At Least 5 Clear Photos Of Your Space.")
                .font(AppFont.manropeMedium(14))
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoBig, matching: .images) {
                    dashedPhotoBox(size: 165, image: images[0])
                }
                .onChange(of: selectedPhotoBig) { _, newValue in
                    loadImage(newValue, index: 0)
                }
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto1, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[1])
                        }
                        .onChange(of: selectedPhoto1) { _, newValue in
                            loadImage(newValue, index: 1)
                        }
                        PhotosPicker(selection: $selectedPhoto2, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[2])
                        }
                        .onChange(of: selectedPhoto2) { _, newValue in
                            loadImage(newValue, index: 2)
                        }
                    }
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto3, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[3])
                        }
                        .onChange(of: selectedPhoto3) { _, newValue in
                            loadImage(newValue, index: 3)
                        }
                        PhotosPicker(selection: $selectedPhoto4, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[4])
                        }
                        .onChange(of: selectedPhoto4) { _, newValue in
                            loadImage(newValue, index: 4)
                        }
                    }
                }
            }
            .padding(.top, 10)
        }
    }
    private func dashedPhotoBox(size: CGFloat, image: UIImage?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.gray,
                    style: StrokeStyle(lineWidth: 1, dash: [6])
                )
                .frame(width: size, height: size)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Circle()
                    .fill(AppColors.primaryYellow)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    )
            }
        }
    }
    private func loadImage(_ item: PhotosPickerItem?, index: Int) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    images[index] = uiImage
                }
            }
        }
    }
    private var roommatesSection: some View {
        HStack(spacing: 10) {
            ForEach(1...6, id: \.self) { num in
                Text("\(num)")
                    .font(AppFont.manropeMedium(16))
                    .frame(minWidth: 50, minHeight: 50)
                    .background(selectedRoommates == num ? AppColors.primaryYellow : AppColors.Black)
                    .foregroundColor(selectedRoommates == num ? AppColors.Black : AppColors.backgroundWhite)
                    .cornerRadius(10)
                    .onTapGesture { selectedRoommates = num }
            }
        }
    }
    private var rentField: some View {
        KeyboardDoneTextField(text: $rent, placeholder: "")
            .padding()
            .background(AppColors.backgroundWhite)
            .cornerRadius(12)
    }
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location: \(savedAddress)")
                .font(AppFont.manropeMedium(14))
            Map(position: $mapPosition) {
                UserAnnotation()
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                Button {
                } label: {
                    HStack {
                        Text("Choose on Map")
                            .foregroundColor(.black)
                            .font(AppFont.manropeMedium(14))
                        Image("arrow")
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryYellow)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding(),
                alignment: .bottom
            )
        }
    }
    private var nextButton: some View {
        let allImagesSelected = images.prefix(5).allSatisfy { $0 != nil }
        let canProceed = allImagesSelected && !selectedAmenities.isEmpty
        return HStack(spacing: 12) {
            Button(action: {
                if canProceed {
                    uploadImages()
                    onNext()
                } else {
                    validator.showValidation("⚠️ Please select all 5 images before proceeding.")
                    validator.showToast = true
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            selectedAmenities.isEmpty
                            ? Color.black.opacity(0.3)
                            : Color.black
                        )
                        .frame(height: 56)
                    Text("Next")
                        .font(AppFont.manropeMedium(16))
                        .foregroundColor(.white)
                }
            }
            .disabled(selectedAmenities.isEmpty)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
    private var header: some View {
        HStack {
            if let url = URL(string: userAuth.image), !userAuth.image.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3)
                            )

                    } else if phase.error != nil {
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                if let savedAddress = KeychainHelper.shared.get(forKey: "address") {
                    Text(savedAddress).font(AppFont.manropeSemiBold(16))
                }
            }
            Spacer()
            Button {
                showNotifications = true
            } label: {
                Image("bell")
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
        }
        .padding(.horizontal)
    }
    private var title: some View {
        VStack(spacing: 5) {
            Text("Add Space Details")
                .font(AppFont.manropeBold(17))
                .multilineTextAlignment(.center)
            Text("These details help others understand your space and vibe before connecting.")
                .font(AppFont.manrope(14))
                .foregroundColor(AppColors.Gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.leading, 2)
        .padding(.trailing, 2)
    }
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppFont.manropeSemiBold(15))
    }
    struct SegmentedView: View {
        let options: [OptionItem]
        @Binding var selected: OptionItem?
        var body: some View {
            HStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    let option = options[index]
                    let isSelected = selected?.id == option.id

                    Text(option.title)
                        .font(AppFont.manropeMedium(14))
                        .foregroundColor(
                            isSelected
                            ? AppColors.Black
                            : AppColors.backgroundWhite
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            isSelected
                            ? AppColors.primaryYellow
                            : AppColors.Black
                        )
                        .overlay(
                            Group {
                                if index != options.count - 1 {
                                    Rectangle()
                                        .fill(AppColors.backgroundWhite)
                                        .frame(width: 1.5)
                                        .frame(maxHeight: .infinity)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selected = option
                            }
                        }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.Black, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    struct StepAmenitiesView: View {
        @ObservedObject var viewModel: BasicModel
        @Binding var selectedAmenities: Set<Int>
        var body: some View {
            ScrollView {
                FlowLayout(spacing: 10) {
                    ForEach(viewModel.amenities) { amenity in
                        AmenityButton(amenity)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
        }
        private func AmenityButton(_ item: OptionItem) -> some View {
            Button {
                toggleAmenity(item.id)
            } label: {
                HStack(spacing: 8) {
                    if let url = URL(string: item.icon ?? "") {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            } else {
                                Image("parking")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }
                        }
                    } else {
                        Image("parking")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    Text(item.title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    selectedAmenities.contains(item.id)
                    ? AppColors.primaryYellow
                    : AppColors.backgroundClear
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
            }
        }
        private func toggleAmenity(_ id: Int) {
            if selectedAmenities.contains(id) {
                selectedAmenities.remove(id)
            } else {
                selectedAmenities.insert(id)
            }
        }
    }
    func uploadImages() {
        let allSelected = images.allSatisfy { $0 != nil }
        guard allSelected else {
            validator.showValidation("⚠️ Please select all 5 images")
            validator.showToast = true
            return
        }
        let imageData = images.compactMap {
            $0?.jpegData(compressionQuality: 0.8)
        }
        let multipartImages: [MultipartImage] = imageData.enumerated().map { index, data in
            return MultipartImage(
                key: "photos[]",
                filename: "photo_\(index).jpg",
                data: data
            )
        }
        let params: [String: Any] = [
            "room_type": selectedSpaceType?.id ?? 0,
            "room_mate_want": selectedRoommates,
            "rent_split": rent,
            "furnish_type": selectedFurnishing?.id ?? 0,
            "amenities": Array(selectedAmenities),
            "location": savedAddress,
            "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
            "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
            "want_to_live_with": selectedGender?.id ?? 0
        ]
        let amenities = Array(selectedAmenities)
        NetworkManager.shared.uploadMultiparts(
            endpoint: APIConstants.Endpoints.AddRoom,
            parameters: params,
            amenities: amenities,
            images: multipartImages,
        ) { (result: Result<SpaceModel, Error>) in
            switch result {
            case .success(let response):
                print("Success:", response)
                userAuth.spaceComplete()
                onNext()
            case .failure(let error):
                print("Error:", error.localizedDescription)
            }
        }
    }
}
