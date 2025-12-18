import SwiftUI

struct YourselfView: View {

    @State private var gender: String = "Male"
    @State private var selectedDay = 17
    @State private var selectedMonth = "December"
    @State private var selectedYear = 2025
    @State private var goToProfilePic = false
    @State private var dobToSend = ""
    @StateObject private var validator = ValidationHelper()
    private let months = [
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]
    private let years = Array((1960...2025).reversed())
    enum ButtonPosition { case left, middle, right }
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    GeometryReader { geo in
                        let width = (geo.size.width - 10) / 2
                        HStack(spacing: 10) {
                            progressBar(width: width, active: true)
                            progressBar(width: width)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal)
                .padding(.top, 65)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        Text("Let’s get to know you better")
                            .font(AppFont.manropeSemiBold(18))
                            .padding(.top, 50)
                        Text("Share your gender and date of birth so we can help you find your perfect vibe match.")
                            .font(AppFont.manrope(14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gender")
                                .font(AppFont.manropeSemiBold(13))
                            HStack(spacing: 0) {
                                genderButton("Male", icon: "male", position: .left)
                                genderButton("Female", icon: "female", position: .middle)
                                genderButton("Other", icon: "other", position: .right)
                            }
                            .frame(height: 80)
                        }
                        .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Date Of Birth")
                                .font(AppFont.manropeSemiBold(13))
                            HStack(spacing: 0) {
                                pickerColumn(items: daysForMonth(), selected: $selectedDay)
                                pickerColumn(items: months, selected: $selectedMonth)
                                pickerColumn(items: years, selected: $selectedYear)
                            }
                            .frame(height: 350)
                        }
                        .padding(.horizontal)
                        Button {
                            adjustDayIfNeeded()
                            let monthIndex = months.firstIndex(of: selectedMonth)! + 1
                            dobToSend = String(
                                format: "%04d-%02d-%02d",
                                selectedYear, monthIndex, selectedDay
                            )
                            print(dobToSend)
                            goToProfilePic = true
                            
                        } label: {
                            Text("Next")
                                .font(AppFont.manropeMedium(16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryYellow)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        } .navigationBarBackButtonHidden(true)
            .toast(message: validator.validationMessage, isPresented: $validator.showToast)
            .ignoresSafeArea()
            .navigationDestination(isPresented: $goToProfilePic) {
                ProfilePicView(gender: gender, dob: dobToSend)
            }
    }
    // MARK: - HELPERS
    private func daysForMonth() -> [Int] {
        let monthIndex = months.firstIndex(of: selectedMonth) ?? 0
        let days: Int
        switch monthIndex {
        case 1:
            let isLeap = (selectedYear % 4 == 0 && selectedYear % 100 != 0) || (selectedYear % 400 == 0)
            days = isLeap ? 29 : 28
        case 3, 5, 8, 10:
            days = 30
        default:
            days = 31
        }
        return Array(1...days)
    }
    private func adjustDayIfNeeded() {
        let max = daysForMonth().last ?? 31
        if selectedDay > max {
            selectedDay = max
        }
    }
    private func progressBar(width: CGFloat, active: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(active ? Color.yellow : Color.gray.opacity(0.2))
            .frame(width: width, height: 4)
    }
    private func genderButton(_ title: String, icon: String, position: ButtonPosition) -> some View {
        let isSelected = gender == title
        let border = isSelected ? AppColors.primaryYellow : Color.gray.opacity(0.3)
        let shape = RoundedCorners(position: position, radius: 15)
        return Button {
            gender = title
        } label: {
            VStack(spacing: 10) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)

                Text(title)
                    .font(AppFont.manropeSemiBold(12))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(border)
            .clipShape(shape)
            .overlay(shape.stroke(border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    struct RoundedCorners: Shape {
        var position: ButtonPosition
        var radius: CGFloat
        func path(in rect: CGRect) -> Path {
            let corners: UIRectCorner = {
                switch position {
                case .left: return [.topLeft, .bottomLeft]
                case .middle: return []
                case .right: return [.topRight, .bottomRight]
                }
            }()
            return Path(
                UIBezierPath(
                    roundedRect: rect,
                    byRoundingCorners: corners,
                    cornerRadii: CGSize(width: radius, height: radius)
                ).cgPath
            )
        }
    }
    private func pickerColumn<T: Hashable & CustomStringConvertible>(
        items: [T],
        selected: Binding<T>
    ) -> some View {
        Picker("", selection: selected) {
            ForEach(items, id: \.self) {
                Text($0.description)
                    .font(AppFont.manropeSemiBold(13))
                    .tag($0)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}
