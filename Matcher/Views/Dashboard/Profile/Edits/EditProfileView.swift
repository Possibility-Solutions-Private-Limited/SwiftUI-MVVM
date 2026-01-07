import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var userAuth: UserAuth
    @State private var selectedPhotoBig: PhotosPickerItem?
    @State private var selectedPhoto1: PhotosPickerItem?
    @State private var selectedPhoto2: PhotosPickerItem?
    @State private var selectedPhoto3: PhotosPickerItem?
    @State private var mainImage: UIImage?
    @State private var img1: UIImage?
    @State private var img2: UIImage?
    @State private var img3: UIImage?
    @State private var isUploading = false
    @State private var aboutYourselfText: String = ""
    @StateObject private var validator = ValidationHelper()
    @StateObject private var PROFILE = ProfileModel()
    let user: User?
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
                    VStack(spacing: 0) {
                        headerView
                            .padding(.top, 10)
                        PhotosPicker(selection: $selectedPhotoBig, matching: .images) {
                            bigDashedBox(image: mainImage) {
                                mainImage = nil
                                selectedPhotoBig = nil
                            }
                        }
                        .onChange(of: selectedPhotoBig) { _, newValue in
                            loadImage(newValue, to: 0)
                        }
                        .padding(.top, 30)
                        GeometryReader { geo in
                            let spacing: CGFloat = 16
                            let size = (geo.size.width - (spacing * 2)) / 3
                            HStack(spacing: spacing) {
                                photoPickerBox(
                                    selection: $selectedPhoto1,
                                    image: img1,
                                    index: 1,
                                    size: size
                                )
                                photoPickerBox(
                                    selection: $selectedPhoto2,
                                    image: img2,
                                    index: 2,
                                    size: size
                                )
                                photoPickerBox(
                                    selection: $selectedPhoto3,
                                    image: img3,
                                    index: 3,
                                    size: size
                                )
                            }
                        }
                        .frame(height: 120)
                        .padding(.top, 20)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Location")
                                .font(AppFont.manropeSemiBold(16))
                            HStack {
                                Text(
                                    KeychainHelper.shared.get(forKey: "saved_address")
                                    ?? "123 Maple Street, New York, NY"
                                )
                                .font(AppFont.manropeMedium(14))
                                .foregroundColor(.black)
                                Spacer()
                                Image("drop")
                                    .frame(width: 32, height: 32)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .padding(.top, 30)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("About you")
                                .font(AppFont.manropeSemiBold(16))
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 130))],
                                spacing: 12
                            ) {
                                aboutChip("Working")
                                aboutChip("Science & Research")
                                aboutChip("Night-shift")
                                aboutChip("Non-veg")
                                aboutChip("No-smoking")
                                aboutChip("Drinking")
                            }
                        }
                        .padding(.top, 24)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About yourself")
                                .font(AppFont.manropeSemiBold(16))
                            ZStack(alignment: .topLeading) {
                                if aboutYourselfText.isEmpty {
                                    Text("type here...")
                                        .font(AppFont.manropeMedium(14))
                                        .foregroundColor(.gray)
                                        .padding(.top, 12)
                                        .padding(.leading, 12)
                                }
                                TextEditor(text: $aboutYourselfText)
                                    .font(AppFont.manropeMedium(14))
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                            }
                            .frame(height: 160)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .padding(.top, 24)
                        Button(action: uploadImages) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.Black)
                                .frame(height: 50)
                                .overlay {
                                    if isUploading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Update")
                                            .font(AppFont.manropeMedium(16))
                                            .foregroundColor(.white)
                                    }
                                }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 30)
                        .disabled(isUploading)
                        .opacity(isUploading ? 0.7 : 1)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            router.isTabBarHidden = true
            loadUserPhotos()
        }
    }
    private func loadUserPhotos() {
        guard let photos = user?.photos else { return }
        if photos.indices.contains(0) {
            loadImageFromURL(photos[0].file ?? "") { mainImage = $0 }
        }
        if photos.indices.contains(1) {
            loadImageFromURL(photos[1].file  ?? "") { img1 = $0 }
        }
        if photos.indices.contains(2) {
            loadImageFromURL(photos[2].file  ?? "") { img2 = $0 }
        }
        if photos.indices.contains(3) {
            loadImageFromURL(photos[3].file  ?? "") { img3 = $0 }
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
            Text("Edit Profile")
                .font(AppFont.manropeSemiBold(16))
            Spacer()
            Spacer()
        }
    }
    func aboutChip(_ text: String) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(AppFont.manropeMedium(14))
            Image("drop")
                .frame(width: 22, height: 22)
                .background(Color.black)
                .cornerRadius(6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.yellow.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    private func photoPickerBox(
        selection: Binding<PhotosPickerItem?>,
        image: UIImage?,
        index: Int,
        size: CGFloat
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            PhotosPicker(selection: selection, matching: .images) {
                smallDashedBox(image: image, size: size)
            }
            .onChange(of: selection.wrappedValue) { _, newValue in
                loadImage(newValue, to: index)
            }
            if let _ = image {
                Button(action: {
                    switch index {
                    case 1:
                        img1 = nil
                        selectedPhoto1 = nil
                    case 2:
                        img2 = nil
                        selectedPhoto2 = nil
                    case 3:
                        img3 = nil
                        selectedPhoto3 = nil
                    default:
                        break
                    }
                }) {
                  Image("crossing")
                }
                .offset(x: 10, y: -20)
            }
        }
    }
    func bigDashedBox(
        image: UIImage?,
        onRemove: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.black)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow.opacity(0.12))
            )
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            if image == nil {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        plusCircle(size: 65, iconSize: 22)
                        Spacer()
                    }
                    Spacer()
                }
            }
            if image != nil {
                Button(action: onRemove) {
                    Image("crossing")
                }
                .offset(x: 10, y: -20)
            }
        }
    }
    func smallDashedBox(image: UIImage?, size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.black)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow.opacity(0.12))
              )
              if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                plusCircle(size: size * 0.45, iconSize: size * 0.18)
            }
        }
    }
    func plusCircle(size: CGFloat, iconSize: CGFloat) -> some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: iconSize, weight: .bold))
            )
    }
    func loadImage(_ item: PhotosPickerItem?, to index: Int) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                switch index {
                case 0: mainImage = img
                case 1: img1 = img
                case 2: img2 = img
                case 3: img3 = img
                default: break
                }
            }
        }
    }
    func uploadImages() {
        guard let mainImage, let img1, let img2, let img3 else {
            validator.showValidation("Please select all images")
            return
        }
        isUploading = true
        let imgs: [MultipartImage] = [
            MultipartImage(key: "photos[]", filename: "main.jpg", data: mainImage.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img1.jpg", data: img1.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img2.jpg", data: img2.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img3.jpg", data: img3.jpegData(compressionQuality: 0.8))
        ]
        print(imgs)
        let params: [String: Any] = [
            "location": KeychainHelper.shared.get(forKey: "saved_address") ?? "",
            "lat": KeychainHelper.shared.get(forKey: "saved_latitude") ?? "",
            "long": KeychainHelper.shared.get(forKey: "saved_longitude") ?? ""
        ]
        PROFILE.SignUpWithImages(images: imgs, params: params) { _ in
            isUploading = false
        }
    }
}
