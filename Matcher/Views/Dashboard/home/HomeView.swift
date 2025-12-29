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
                    if userAuth.steps {
                        if userAuth.space {
                            header
                            Text("Nearby Rooms & Roommates")
                                .font(AppFont.manropeExtraBold(18))
                                .padding(.horizontal)
                            searchBar
                            ZStack {
                                ForEach(profiles) { profiles in
                                    SwipeCard(
                                        profiles: profiles,
                                        maxHeight: geo.size.height * 2
                                    ) {
                                        removeProfile(profiles)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            Spacer(minLength: 5)
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
        .onAppear {
            if userAuth.steps {
                if userAuth.space {
                    dashboardView.loadDashboard(params: [
                                "lat": "",
                                "long": "",
                                "age": "",
                                "distance": "",
                                "want_to_live_with": "",
                                "food_preference": "",
                                "party_preference": "",
                                "smoking": "",
                                "drinking": ""
                            ])
                }
            }else{
                cards = initialCards
            }
            if viewModel.professionalFields.isEmpty {
                viewModel.fetchBasicData()
            }
        }
        .onReceive(dashboardView.$profiles) { newProfiles in
            profiles = newProfiles
        }
        .onChange(of: selections.selectedRole) {
            rebuildCards()
        }
    }
    // main CARD======
    struct SwipeCard: View {
        let profiles: Profiles
        let maxHeight: CGFloat
        let onRemove: () -> Void
        @State private var currentImageIndex: Int = 0
        private let sliderHeight: CGFloat = 420
        private let autoSlideTime: TimeInterval = 3
        @State private var offset: CGSize = .zero
        @State private var rotation: Double = 0
        private func swipeLeft() {
            withAnimation(.interpolatingSpring(stiffness: 35, damping: 18)) {
                offset = CGSize(width: -500, height: 0)
                rotation = -18
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onRemove() }
        }
        private func swipeRight() {
            withAnimation(.interpolatingSpring(stiffness: 35, damping: 18)) {
                offset = CGSize(width: 500, height: 0)
                rotation = 18
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onRemove() }
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
                        PartyPreferencesView()
                        RoomPhotosDisplayView(photos: profiles.rooms?.first?.photos ?? [])
                        RoomShortInfoSection(
                            spaceType: profiles.rooms?.first?.roomType ?? "",
                            rentSplit: profiles.rooms?.first?.rentSplit ?? "",
                            furnishing: profiles.rooms?.first?.furnishType ?? "",
                            spaceFor: profiles.rooms?.first?.wantToLiveWith ?? ""
                        )
                        ShowAmenitiesView(
                            profiles: profiles,
                        )
                        locationBox
                    }
                    .padding(10)
                    .background(LinearGradient(colors: [.splashTop, .splashBottom],
                                               startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 0)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                    }
                    .onEnded { gesture in
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
                }
            )
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
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .onAppear { startAutoSlide() }
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
                    VStack(spacing: 14) {
                        circleButton(icon: "xmark", bg: .blue) { swipeLeft() }
                        circleButton(icon: "heart.fill", bg: .red) { swipeRight() }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 5)
        }
        private func nextImage() {
            guard let total = profiles.photos?.count, total > 0 else { return }
            if currentImageIndex < total - 1 {
                currentImageIndex += 1
            }
        }
        private func previousImage() {
            guard let total = profiles.photos?.count, total > 0 else { return }
            if currentImageIndex > 0 {
                currentImageIndex -= 1
            }
        }
        private func startAutoSlide() {
            Timer.scheduledTimer(withTimeInterval: autoSlideTime, repeats: true) { _ in
                let count = profiles.photos?.count ?? 1
                if count > 1 {
                    withAnimation(.easeInOut) {
                        currentImageIndex = (currentImageIndex + 1) % count
                    }
                }
            }
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
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        struct habitGrid: View {
            var FoodPreference: String
            var Smoking: String
            var WorkShift: String
            var Drinking: String

            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                     LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 5) {
                         Items(title: "Food Choice", value: FoodPreference, theme: .dark)
                         Items(title: "Smoking", value: Smoking, theme: .yellow)
                         Items(title: "Shift", value: WorkShift, theme: .yellow)
                         Items(title: "Drinking", value: Drinking, theme: .dark)
                    }
                }
                .padding(.top, 10)
            }
            @ViewBuilder
            private func Items(title: String, value: String, theme: ItemsTheme) -> some View {
                VStack(spacing: 2) {
                    Text(title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black.opacity(0.7)).padding(.bottom,10)
                    Text(value.cleanDecimal())
                        .font(AppFont.manropeMedium(12))
                        .foregroundColor(theme == .yellow ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
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
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                            Text("Not Party Person")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.36, blue: 0.43))
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 20)
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
                VStack(spacing: 2) {
                    Text(title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black.opacity(0.7)).padding(.bottom,10)
                    Text(value.cleanDecimal())
                        .font(AppFont.manropeMedium(12))
                        .foregroundColor(theme == .yellow ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 44)
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
                            .padding(.top, 10)
                            .padding(.horizontal)
                        } else {
                            Text("No amenities available")
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.gray)
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
                .background(Color.black.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
            }
        }
        private var locationBox: some View {
            HStack {
                Text("Location :")
                    .font(AppFont.manropeExtraBold(14))
                    .foregroundColor(.black)
                
                Text("\(profiles.rooms?.first?.location ?? "")")
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image("vack")
                    .frame(width: 30, height: 25)
                    .background(Color.black)
                    .cornerRadius(8)

            }
            .frame(height: 44)
            .padding(.horizontal, 16)
            .background(Color.yellow)
            .cornerRadius(12)
        }
        private func circleButton(icon: String, bg: Color, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(AppFont.manrope(15))
                    .foregroundColor(.white)
                    .padding()
                    .background(bg)
                    .clipShape(Circle())
            }
        }
    }
    private func removeProfile(_ profile: Profiles) {
        withAnimation(.spring()) {
            profiles.removeAll { $0.id == profile.id }
            if profiles.isEmpty {
                showFinalStep = 1
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
            Image("bell")
        }
        .padding(.horizontal)
    }
    var searchBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Perfect Room Starts Here")
                    .font(.callout.bold())
                Text("Discover Your Next Room & Roommate")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Image(systemName: "slider.horizontal.3")
                .padding(6)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Image(systemName: "map")
                .padding(6)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
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
            print("Selected Role: \(selections.selectedRole)")
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
            print("Selected Shift: \(selections.selectedShift)")
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
            print("Selected Shift: \(selections.selectedShift)")
            print("Selected Food: \(selections.selectedFood)")
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
            print(selections.selectedParties ?? 0)
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
            print("Selected Shift: \(selections.selectedShift)")
            print("Selected Food: \(selections.selectedFood)")
            print("Selected Parties:",selections.selectedParties ?? 0)
            print("Selected Smoke: \(selections.selectedSmoke)")
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
            print("Selected Shift: \(selections.selectedShift)")
            print("Selected Food: \(selections.selectedFood)")
            print("Selected Parties:",selections.selectedParties ?? 0)
            print("Selected Smoke: \(selections.selectedSmoke)")
            print("Selected Drink: \(selections.selectedDrink)")
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
            print("Selected Role: \(selections.selectedRole)")
            print("Selected Category:",selections.selectedCategory ?? 0)
            print("Selected Shift: \(selections.selectedShift)")
            print("Selected Food: \(selections.selectedFood)")
            print("Selected Parties:",selections.selectedParties ?? 0)
            print("Selected Smoke: \(selections.selectedSmoke)")
            print("Selected Drink: \(selections.selectedDrink)")
            print("Selected About: \(selections.selectedAbout)")
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
                print("Selected Role: \(selections.selectedRole)")
                print("Selected Category:",selections.selectedCategory ?? 0)
                print("Selected Shift: \(selections.selectedShift)")
                print("Selected Food: \(selections.selectedFood)")
                print("Selected Parties:",selections.selectedParties ?? 0)
                print("Selected Smoke: \(selections.selectedSmoke)")
                print("Selected Drink: \(selections.selectedDrink)")
                print("Selected About: \(selections.selectedAbout)")
                print("Selected room Option: \(selections.roomOption)")
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
            Image("bell")
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
            Image("bell")
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
            "professional_field": selections.selectedCategory ?? 0,
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
                .padding(.bottom, 40)
            }
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
                    print("Selected Space Type:", selectedSpaceType ?? "")
                    print("Selected Roommates:", selectedRoommates)
                    print("Rent:", rent)
                    print("Selected Furnishing:", selectedFurnishing ?? "")
                    print("Selected Gender:", selectedGender ?? "")
                    print("Selected Amenities:", selectedAmenities)
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
            Image("bell")
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
            "lat": locationManager.latitude,
            "long": locationManager.longitude,
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
            case .failure(let error):
                print("Error:", error.localizedDescription)
            }
        }
    }
}
