import SwiftUI

struct UserProfile: Identifiable {
    var id = UUID()
    var name: String
    var age: Int
    var job: String
    var location: String
    var shift: String
    var image: String
}
struct LikeView: View {
    @EnvironmentObject var userAuth: UserAuth
    let users: [UserProfile] = [
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "men1"),
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "girl1"),
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "girl2"),
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "men2"),
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "girl3"),
        .init(name: "Caleb Morgan", age: 24, job: "Software Engineer", location: "Delhi", shift: "Day Shift", image: "girl4")
    ]
    private let spacing: CGFloat = 14
    private let horizontalPad: CGFloat = 16
    var body: some View {
        GeometryReader { geo in
            let width = (geo.size.width - (horizontalPad * 2) - spacing) / 2
            ZStack {
                LinearGradient(
                    colors: [.splashTop, .splashBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    header
                    ZStack {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: [
                                GridItem(.fixed(width), spacing: spacing),
                                GridItem(.fixed(width), spacing: spacing)
                            ], spacing: 18) {
                                ForEach(users) { user in
                                    ProfileCardView(user: user, width: width)
                                        .frame(width: width, height: 200)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 5)
                }
            }
        }
        .onAppear {
//            if viewModel.professionalFields.isEmpty {
//                viewModel.fetchBasicData()
//            }
        }
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
}
struct ProfileCardView: View {
    let user: UserProfile
    let width: CGFloat
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(user.image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20))
            LinearGradient(colors: [.black.opacity(0.0),
                                    .black.opacity(0.65)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(user.name) \(user.age)")
                        .font(AppFont.manropeSemiBold(18))
                        .foregroundColor(.white)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 15))
                }
                Text("\(user.job), \(user.location)")
                    .font(AppFont.manropeMedium(13))
                    .foregroundColor(.white.opacity(0.9))
                Text(user.shift)
                    .font(AppFont.manropeMedium(11))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .padding(.top, 6)
            }
            .padding(.leading, 14)
            .padding(.bottom, 14)
        }
        .background(AppColors.backgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppColors.Black.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}
