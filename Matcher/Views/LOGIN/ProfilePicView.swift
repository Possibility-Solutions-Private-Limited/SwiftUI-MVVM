import SwiftUI
import PhotosUI

struct ProfilePicView: View {
    @Environment(\.dismiss) var dismiss
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
    let gender: String
    let dob: String
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    GeometryReader { geo in
                        let width = (geo.size.width - 10) / 2
                        HStack(spacing: 10) {
                            progressBar(width: width)
                            progressBar(width: width, active: true)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal)
                .padding(.top, 65)
                Text("Let your next roomie meet you visually")
                    .font(AppFont.manropeSemiBold(18))
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                Text("Add Your Profile Picture")
                    .font(AppFont.manrope(14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
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
                Spacer()
                HStack {
                    Button(action: { dismiss() }) {
                        RoundedRectangle(cornerRadius:20)
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width:70, height:50)
                            .overlay(
                                Image("back")
                                    .font(.system(size:20, weight:.heavy))
                                    .foregroundColor(.black)
                            )
                    }
                    Spacer()
                    Button(action: { uploadImages() }) {
                        if isUploading {
                            ProgressView()
                                .frame(width:260, height:50)
                        } else {
                            Text("Next")
                                .font(AppFont.manropeMedium(16))
                                .frame(width:260, height:50)
                                .background(AppColors.primaryYellow)
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    }
                    .disabled(isUploading)
                }
                .padding(.horizontal,24)
                .padding(.bottom,40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
            .ignoresSafeArea()
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
        .padding(.horizontal, 24)
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
    // MARK: - IMAGE LOAD
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
    // MARK: - UPLOAD & PUSH
    func uploadImages() {
        // Validate all selected images exist
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
            "gender": gender.lowercased(),
            "dob": dob,
        ]
        PROFILE.SignUpWithImages(images: imgs, params: params) { success, error in
            isUploading = false
            if success {
                let firstName = KeychainHelper.shared.get(forKey: "first_name") ?? ""
                let emailKey  = KeychainHelper.shared.get(forKey: "email") ?? ""
                let mobile    = KeychainHelper.shared.get(forKey: "mobile") ?? ""
                let gender    = KeychainHelper.shared.get(forKey: "gender") ?? ""
                userAuth.firstName = firstName
                userAuth.email     = emailKey
                userAuth.mobile    = mobile
                userAuth.gender    = gender
                userAuth.login(email: emailKey, password: "12345")
                print("Uploaded successfully!")
            } else {
                print(error ?? "Unknown error")
            }
        }
    }
}
