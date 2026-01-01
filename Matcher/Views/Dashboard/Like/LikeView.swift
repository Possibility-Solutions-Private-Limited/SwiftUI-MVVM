import SwiftUI

struct LikeView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject var Interaction = InteractionModel()
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
                        if Interaction.InteractedUser.isEmpty {
                            NoRoomsView()
                        }else{
                            ScrollView(showsIndicators: false) {
                                LazyVGrid(columns: [
                                    GridItem(.fixed(width), spacing: spacing),
                                    GridItem(.fixed(width), spacing: spacing)
                                ], spacing: 18) {
                                    ForEach(Interaction.InteractedUser) { Interaction in
                                        ProfileCardView(Interaction: Interaction, width: width)
                                            .frame(width: width, height: 200)
                                    }
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
            Interaction.fetchInteraction()
        }
    }
    struct NoRoomsView: View {
        var body: some View {
            VStack(spacing: 0) {
                Image("likiy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("No Matches Nearby")
                    .font(AppFont.manropeBold(18))
                    .foregroundColor(.black)

                Text("Try changing your location or preferences ")
                    .font(AppFont.manrope(12))
                    .foregroundColor(.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .tabBar)
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
    let Interaction: InteractedUser
    let width: CGFloat
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageFile = Interaction.user?.photos?.first?.file, !imageFile.isEmpty {
                if let url = URL(string: imageFile) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: width, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 3)
                    )
                } else {
                    Image(imageFile)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 3)
                      )
                 }
            }
            LinearGradient(colors: [.black.opacity(0.0),
                                    .black.opacity(0.65)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 0) {
                    Text("\(Interaction.user?.first_name ?? "") \(Interaction.user?.last_name ?? "") 🌼")
                        .font(AppFont.manropeSemiBold(14))
                        .foregroundColor(.white)
                    Text(" \(calculateAge(Interaction.user?.dob ?? ""))")
                        .font(AppFont.manropeExtraBold(16))
                        .foregroundColor(.white)
                }
                Text(Interaction.user?.profile?.professional_field_data?.title ?? "")
                    .font(AppFont.manropeMedium(12))
                    .foregroundColor(.white.opacity(0.9))
                Text(Interaction.user?.profile?.work_shift ?? "Day Shift")
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
