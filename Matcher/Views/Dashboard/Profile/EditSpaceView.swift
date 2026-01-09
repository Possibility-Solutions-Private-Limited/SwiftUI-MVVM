import SwiftUI
import PhotosUI
import MapKit

struct EditSpaceView: View {
    @State private var showNotifications = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var viewModel = BasicModel()
    @StateObject private var selections = UserSelections()
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
    let user: User?
    var onUpdate: () -> Void
    init(
        user: User?,
        onUpdate: @escaping () -> Void
    ) {
        self.user = user
        self.onUpdate = onUpdate
    }
    @State private var hiddenPlusIndexes: Set<Int> = []
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.splashTop, .splashBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerView
                        title
                    }
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
              }
         }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
        .onAppear {
            router.isTabBarHidden = true
            viewModel.fetchBasicData(param: [
                "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
                "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
                ]) {
                    loadUserPhotos()
                    if let room = user?.rooms?.first {
                        if let roomTypeStr = room.roomType {
                            selectedSpaceType = viewModel.roomTypes.first {
                                $0.title.lowercased() == roomTypeStr.lowercased()
                            }
                        }
                        if let furnishStr = room.furnishType {
                            selectedFurnishing = viewModel.furnishTypes.first {
                                $0.title.lowercased() == furnishStr.lowercased()
                            }
                        }
                        if let genderStr = room.wantToLiveWith {
                            selectedGender = viewModel.genders.first {
                                $0.title.lowercased() == genderStr.lowercased()
                        }
                    }
                    selectedRoommates = room.roomMateWant ?? 0
                    rent = room.rentSplit ?? ""
                    if let amenities = room.amenities {
                        selectedAmenities = Set(amenities.map { $0.id ?? 0 })
                    }
                }
            }
        }
        .onChange(of: locationManager.latitude) { _, _ in
            updateCamera()
        }
    }
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
                router.isTabBarHidden = false
            } label: {
                Circle()
                    .fill(AppColors.primaryYellow)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    )
            }
            Spacer()
            Text("Edit Space Details")
                .font(AppFont.manropeSemiBold(16))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top,10)
    }
    private func loadUserPhotos() {
        guard let photos = user?.rooms?.first?.photos else { return }
        for (index, photo) in photos.prefix(5).enumerated() {
            loadImageFromURL(photo.file ?? "") { image in
                DispatchQueue.main.async {
                    images[index] = image
                }
            }
        }
    }
    private func loadImageFromURL(
        _ urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                completion(UIImage(data: data))
            } catch {
                completion(nil)
            }
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
                    dashedPhotoBox(
                        size: 165,
                        image: images[0]
                    ) {
                        images[0] = nil
                        selectedPhotoBig = nil
                    }
                }
                .onChange(of: selectedPhotoBig) { _, newValue in
                    loadImage(newValue, index: 0)
                }
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto1, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[1]) {
                                images[1] = nil
                                selectedPhoto1 = nil
                            }
                        }
                        .onChange(of: selectedPhoto1) { _, newValue in
                            loadImage(newValue, index: 1)
                        }
                        PhotosPicker(selection: $selectedPhoto2, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[2]) {
                                images[2] = nil
                                selectedPhoto2 = nil
                            }
                        }
                        .onChange(of: selectedPhoto2) { _, newValue in
                            loadImage(newValue, index: 2)
                        }
                    }
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto3, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[3]) {
                                images[3] = nil
                                selectedPhoto3 = nil
                            }
                        }
                        .onChange(of: selectedPhoto3) { _, newValue in
                            loadImage(newValue, index: 3)
                        }
                        PhotosPicker(selection: $selectedPhoto4, matching: .images) {
                            dashedPhotoBox(size: 80, image: images[4]) {
                                images[4] = nil
                                selectedPhoto4 = nil
                            }
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
    private func dashedPhotoBox(
        size: CGFloat,
        image: UIImage?,
        onRemove: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [6]))
                .frame(width: size, height: size)
             Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
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
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            if image != nil {
                Button(action: onRemove) {
                    Image("crossing")
                }
                .offset(x: 10, y: -20)
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
                    onUpdate()
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
    private var title: some View {
        VStack(spacing: 5) {
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
            endpoint: APIConstants.Endpoints.EditRoom + "/\(user?.rooms?.first?.id ?? 0)",
            parameters: params,
            amenities: amenities,
            images: multipartImages,
        ) { (result: Result<SpaceModel, Error>) in
            switch result {
            case .success(let response):
                print("Success:", response)
                DispatchQueue.main.async {
                    isUploading = false
                    router.isTabBarHidden = false
                    onUpdate()
                    dismiss()
                }
            case .failure(let error):
                print("Error:", error.localizedDescription)
            }
        }
    }
}
