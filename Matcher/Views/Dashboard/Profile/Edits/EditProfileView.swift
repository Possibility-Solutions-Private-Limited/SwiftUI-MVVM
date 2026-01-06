import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var selectedPhotoBig: PhotosPickerItem?
    @State private var selectedPhoto1: PhotosPickerItem?
    @State private var selectedPhoto2: PhotosPickerItem?
    @State private var selectedPhoto3: PhotosPickerItem?
    @State private var mainImage: UIImage?
    @State private var img1: UIImage?
    @State private var img2: UIImage?
    @State private var img3: UIImage?
    @State private var isUploading = false
    @StateObject private var validator = ValidationHelper()
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var model = LoginModel()
    @StateObject private var PROFILE = ProfileModel()
    @State private var aboutYourselfText: String = ""
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            PhotosPicker(selection: $selectedPhotoBig, matching: .images) {
                                bigDashedBox(image: mainImage)
                            }
                            .onChange(of: selectedPhotoBig) { _, newValue in
                                loadImage(newValue, to: 0)
                            }
                            .padding(.top, 30)
                            HStack(spacing: 20) {
                                photoPickerBox(selection: $selectedPhoto1, image: img1, index: 1)
                                photoPickerBox(selection: $selectedPhoto2, image: img2, index: 2)
                                photoPickerBox(selection: $selectedPhoto3, image: img3, index: 3)
                            }
                            .padding(.top, 22)
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
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(14)
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
                                Text("Party Preferences")
                                    .font(AppFont.manropeSemiBold(16))

                                aboutChip("Not Party person")
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
                                        HStack(spacing: 8) {
                                            if isUploading {
                                                ProgressView()
                                                    .tint(.white)
                                            }
                                            Text("Update")
                                                .font(AppFont.manropeMedium(16))
                                                .foregroundColor(.white)
                                        }
                                    }
                            }
                            .padding(.top, 24)
                            .allowsHitTesting(!isUploading)
                            .opacity(isUploading ? 0.7 : 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .safeAreaInset(edge: .top) {
                headerView
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .background(Color.white)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            router.isTabBarHidden = true
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
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .overlay(
                        Image(systemName: "arrow.left")
                            .foregroundColor(AppColors.Black)
                    )
            }
            Spacer()
            HStack(spacing: 5) {
                Text("Edit Profile").font(AppFont.manropeSemiBold(16))
            }
            Spacer()
            Spacer()
        }
    }
    func aboutChip(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(AppFont.manropeMedium(14))
                .foregroundColor(.black)
            Image(systemName: "pencil")
                .font(.system(size: 12))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    private func progressBar(width: CGFloat, active: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(active ? Color.yellow : Color.gray.opacity(0.2))
            .frame(width: width, height: 4)
    }
    private func photoPickerBox(
        selection: Binding<PhotosPickerItem?>,
        image: UIImage?,
        index: Int
    ) -> some View {
        PhotosPicker(selection: selection, matching: .images) {
            smallDashedBox(image: image)
        }
        .onChange(of: selection.wrappedValue) { _, newValue in
            loadImage(newValue, to: index)
        }
    }
    func bigDashedBox(image: UIImage?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.black)
                .frame(height: 300)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow.opacity(0.12))
                )
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                plusCircle(size: 65, iconSize: 22)
            }
        }
    }
    func smallDashedBox(image: UIImage?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.black)
                .frame(width: 100, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow.opacity(0.12))
                )
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                plusCircle(size: 45, iconSize: 18)
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
                    .foregroundColor(.black)
            )
    }
    func loadImage(_ item: PhotosPickerItem?, to index: Int) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {

                switch index {
                case 0: mainImage = uiImage
                case 1: img1 = uiImage
                case 2: img2 = uiImage
                case 3: img3 = uiImage
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
        let params: [String: Any] = [
           
            "location": "\(KeychainHelper.shared.get(forKey: "saved_address") ?? "")",
            "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
            "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
        ]
        PROFILE.SignUpWithImages(images: imgs, params: params) { response in
            guard let response else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
                return
            }
            guard response.success == true else {
                validator.showValidation(response.message ?? "")
                validator.showToast = true
                isUploading = false
                return
            }
            let data = response.data
            isUploading = false
            KeychainHelper.shared.save(data?.firstName ?? "", forKey: "first_name")
            KeychainHelper.shared.save(data?.email ?? "", forKey: "email")
            KeychainHelper.shared.save(data?.mobile ?? "", forKey: "mobile")
            KeychainHelper.shared.save(data?.gender ?? "", forKey: "gender")
            KeychainHelper.shared.saveInt(data?.id ?? 0, forKey: "userId")
            if let imageFile = data?.photos?.first?.file, !imageFile.isEmpty {
                KeychainHelper.shared.save(imageFile, forKey: "image")
                print("imageFile",imageFile)
                userAuth.image = imageFile
            }
            userAuth.firstName = data?.firstName ?? ""
            userAuth.email = data?.email ?? ""
            userAuth.mobile = data?.mobile ?? ""
            userAuth.gender = data?.gender ?? ""
            userAuth.login(email: userAuth.email, password: userAuth.mobile)
        }
    }
}
