import SwiftUI
import MapKit
import CoreLocation
import PhotosUI
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
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
    @StateObject private var PROFILE = UpdateProfileModel()
    @StateObject private var viewModel = BasicModel()
    @StateObject private var selections = UserSelections()
    @State private var showLocationSheet = false
    @State private var currentLocation: String = ""
    @State private var lat: String = ""
    @State private var long: String = ""
    let user: User?
    var onUpdate: () -> Void
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
                        .padding(.top, 20)
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
                                .font(AppFont.manropeSemiBold(18))
                            HStack {
                                Text(currentLocation)
                                    .font(AppFont.manropeMedium(14))
                                    .foregroundColor(.black)
                                Spacer()
                                Image("drop")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .padding(6)
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .onTapGesture {
                                showLocationSheet = true
                            }
                        }
                        .padding(.top, 20)
                        .sheet(isPresented: $showLocationSheet) {
                            EditLocationView(
                                location: currentLocation.isEmpty
                                ? (user?.rooms?.first?.location ?? "")
                                : currentLocation
                            ) { newLocation, latitude, longitude in

                                currentLocation = newLocation
                                lat = String(latitude)
                                long = String(longitude)

                                showLocationSheet = false

                                print("New location selected:", newLocation)
                                print("Lat:", lat)
                                print("Long:", long)
                            }
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About you")
                                .font(AppFont.manropeSemiBold(18))
                                .foregroundColor(.black)
                            AboutChipView(
                                viewModel: viewModel,
                                user:user,
                                selections: selections
                            )
                        }
                        .padding(.top,20)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Party Preferences")
                                .font(AppFont.manropeSemiBold(18))
                                .foregroundColor(.black)
                            PreferenceChipView(
                                viewModel: viewModel,
                                user:user,
                                selections: selections
                            )
                        }
                        .padding(.top,20)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About yourself")
                                .font(AppFont.manropeSemiBold(18))
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
                                    .keyboardType(.default)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil
                                                )
                                            }
                                        }
                                    }
                            }
                            .frame(height: 160)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .padding(.top,20)
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
                        .padding(.top, 40)
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
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
        .onAppear {
            router.isTabBarHidden = true
            viewModel.fetchBasicData(param: [
                "lat": "\(KeychainHelper.shared.get(forKey: "saved_latitude") ?? "")",
                "long": "\(KeychainHelper.shared.get(forKey: "saved_longitude") ?? "")",
                ]) {
                loadUserPhotos()
                aboutYourselfText = user?.profile?.aboutYourself ?? ""
                currentLocation = user?.location ?? ""
                lat = user?.lat ?? ""
                long = user?.long ?? ""
            }
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
    enum AboutSheetType: Identifiable {
        case working(String)
        case science(String)
        case nightShift(String)
        case nonVeg(String)
        case noSmoking(String)
        case drinking(String)
        var id: String { "\(String(describing: self))-\(value)" }
        var value: String {
            switch self {
            case .working(let v),
                 .science(let v),
                 .nightShift(let v),
                 .nonVeg(let v),
                 .noSmoking(let v),
                 .drinking(let v):
                return v
            }
        }
    }
    func title(for sheet: AboutSheetType) -> String {
        switch sheet {
        case .noSmoking(let value):
            return "Smoking: \(value)"
        case .drinking(let value):
            return "Drinking: \(value)"
        default:
            return sheet.value
        }
    }
    struct AboutChipView: View {
        @State private var activeSheet: AboutSheetType?
        @ObservedObject var viewModel: BasicModel
        let user: User?
        @ObservedObject var selections: UserSelections
        private var about: [String] {
            var items: [String] = []
            if !selections.selectedRole.isEmpty {
                items.append(selections.selectedRole)
            }
            if selections.selectedRole.lowercased() == "working" {
                let cat = selections.selectedCategoryStr.isEmpty ? "Select Category" : selections.selectedCategoryStr
                items.append(cat)
            }
            if !selections.selectedShift.isEmpty {
                items.append(selections.selectedShift)
            }
            if !selections.selectedFood.isEmpty {
                items.append(selections.selectedFood)
            }
            if !selections.selectedSmoke.isEmpty {
                items.append("Smoking: \(selections.selectedSmoke)")
            }
            if !selections.selectedDrink.isEmpty {
                items.append("Drinking: \(selections.selectedDrink)")
            }
            return items
        }
        var body: some View {
            VStack(alignment: .leading) {
                FlowLayout(spacing: 10) {
                    ForEach(about, id: \.self) { item in
                        aboutItem(item)
                            .onTapGesture {
                                if let sheet = sheetType(for: item) {
                                    activeSheet = sheet
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .sheet(item: $activeSheet) { sheet in
                sheetView(for: sheet)
            }
            .onAppear {
                selections.selectedRole = user?.profile?.describeYouBest?.capitalized ?? ""
                selections.selectedCategory = user?.profile?.professionalField
                selections.selectedCategoryStr = user?.profile?.professionalFieldData?.title?.capitalized ?? ""
                selections.selectedShift = user?.profile?.workShift?.capitalized ?? ""
                selections.selectedFood = user?.profile?.foodPreference?.capitalized ?? ""
                selections.selectedSmoke = user?.profile?.smoking?.capitalized ?? ""
                selections.selectedDrink = user?.profile?.drinking?.capitalized ?? ""
            }
        }
        private func aboutItem(_ text: String) -> some View {
            HStack(spacing: 8) {
                Text(text)
                    .font(AppFont.manropeMedium(14))
                    .lineLimit(1)
                Image("drops")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
        private func sheetType(for item: String) -> AboutSheetType? {
            let normalizedItem = item
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            if normalizedItem == selections.selectedRole.lowercased() {
                return .working(item)
            }
            if normalizedItem == selections.selectedCategoryStr.lowercased() {
                return .science(item)
            }
            if normalizedItem == selections.selectedShift.lowercased() {
                return .nightShift(item)
            }
            if normalizedItem == selections.selectedFood.lowercased() {
                return .nonVeg(item)
            }
            if normalizedItem == "smoking: \(selections.selectedSmoke)".lowercased() {
                return .noSmoking(selections.selectedSmoke)
            }
            if normalizedItem == "drinking: \(selections.selectedDrink)".lowercased() {
                return .drinking(selections.selectedDrink)
            }
            return nil
        }
        @ViewBuilder
        private func sheetView(for sheet: AboutSheetType) -> some View {
            switch sheet {
            case .working:
                StepOneView(viewModel: viewModel, selections: selections)
            case .science:
                StepTwoView(viewModel: viewModel, selections: selections)
            case .nightShift:
                StepThreeView(viewModel: viewModel, selections: selections)
            case .nonVeg:
                StepFourView(viewModel: viewModel, selections: selections)
            case .noSmoking:
                StepSixView(viewModel: viewModel, selections: selections)
            case .drinking:
                StepSevenView(viewModel: viewModel, selections: selections)
            }
        }
    }
    struct StepOneView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
            )
        }
        func roleCard(title: String, icon: String) -> some View {
            Button {
                selections.selectedRole = title
                if selections.selectedRole.lowercased() == "working" {
                    selections.selectedCategoryStr = "Select Category"
                }
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedRole.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
            .disabled(selections.selectedRole.isEmpty)
            .padding(.bottom, 8)
        }
    }
    struct StepTwoView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
        }
        private func CategoryButton(_ field: OptionItem) -> some View {
            Button {
                selections.selectedCategory = field.id
                selections.selectedCategoryStr = field.title.capitalized
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedCategory == nil ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
            .disabled(selections.selectedCategory == nil)
            .padding(.bottom, 8)
        }
    }
    struct StepThreeView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedShift.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
            .disabled(selections.selectedShift.isEmpty)
            .padding(.bottom, 8)
        }
    }
    struct StepFourView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedFood.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
            .disabled(selections.selectedFood.isEmpty)
            .padding(.bottom, 8)
        }
    }
    struct StepFiveView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
        }
        private func PartyButton(_ field: OptionItem) -> some View {
            Button {
                selections.selectedParties = field.id
                selections.selectedPartiesStr = field.title.capitalized
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedParties == nil ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
            .disabled(selections.selectedParties == nil)
            .padding(.bottom, 8)
        }
    }
    struct StepSixView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedSmoke.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
             )
            .disabled(selections.selectedSmoke.isEmpty)
            .padding(.bottom, 8)
        }
    }
    struct StepSevenView: View {
        @ObservedObject var viewModel: BasicModel
        @ObservedObject var selections: UserSelections
        @Environment(\.dismiss) private var dismiss
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
                dismiss()
            }) {
                Text("Update")
                    .font(AppFont.manropeBold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        selections.selectedDrink.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                     )
             )
            .disabled(selections.selectedDrink.isEmpty)
            .padding(.bottom, 8)
        }
    }
    struct PreferenceChipView: View {
        @State private var showSheet = false
        @ObservedObject var viewModel: BasicModel
        let user: User?
        @ObservedObject var selections: UserSelections
        private var about: [String] {
            var items: [String] = []
            if !selections.selectedPartiesStr.isEmpty {
                items.append(selections.selectedPartiesStr)
            }
            return items
        }
        var body: some View {
            VStack(alignment: .leading) {
                FlowLayout(spacing: 10) {
                    ForEach(about, id: \.self) { item in
                        aboutItem(item)
                            .onTapGesture {
                                showSheet = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $showSheet) {
                StepFiveView(viewModel: viewModel, selections: selections)
            }
            .onAppear {
                selections.selectedParties = user?.profile?.intoParties
                selections.selectedPartiesStr =
                    user?.profile?.intoPartiesData?.title?.capitalized ?? ""
            }
        }
        private func aboutItem(_ text: String) -> some View {
            HStack(spacing: 8) {
                Text(text)
                    .font(AppFont.manropeMedium(14))
                    .lineLimit(1)
                Image("drops")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
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
        let role = selections.selectedRole.lowercased()
            let categoryStr = selections.selectedCategoryStr.trimmingCharacters(in: .whitespacesAndNewlines)
            if role != "student" && categoryStr == "Select Category" {
                validator.showValidation("Please select category")
                return
        }
        isUploading = true
        let imgs: [MultipartImage] = [
            MultipartImage(key: "photos[]", filename: "main.jpg", data: mainImage.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img1.jpg", data: img1.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img2.jpg", data: img2.jpegData(compressionQuality: 0.8)),
            MultipartImage(key: "photos[]", filename: "img3.jpg", data: img3.jpegData(compressionQuality: 0.8))
        ]
        let professionalFieldValue: Int? = selections.selectedRole.lowercased() == "student" ? nil : selections.selectedCategory
        let params: [String: Any] = [
            "describe_you_best": selections.selectedRole.lowercased(),
            "professional_field": professionalFieldValue ?? "",
            "work_shift":selections.selectedShift.lowercased(),
            "food_preference":selections.selectedFood.lowercased(),
            "into_parties":selections.selectedParties ?? "",
            "smoking":selections.selectedSmoke.lowercased(),
            "drinking":selections.selectedDrink.lowercased(),
            "about_yourself":aboutYourselfText,
            "do_you_have_room":user?.profile?.doYouHaveRoom ?? "",
            "want_live_with":user?.profile?.wantLiveWith ?? "",
            "location": currentLocation,
            "lat": lat,
            "long": long,
        ]
        print(params)
        PROFILE.UpdateProfile(images: imgs, params: params) { _ in
            DispatchQueue.main.async {
                isUploading = false
                router.isTabBarHidden = false
                onUpdate()
                dismiss()
            }
        }
    }
}
