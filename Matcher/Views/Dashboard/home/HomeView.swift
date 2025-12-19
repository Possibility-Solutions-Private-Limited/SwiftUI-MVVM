import SwiftUI
struct Card: Identifiable {
    let id = UUID()
    let step: Int
}
struct HomeView: View {
    @State private var cards: [Card] = []
    @State private var selectedRole = ""
    @State private var selectedCategory = ""
    @State private var selectedShift = ""
    @State private var selectedFood = ""
    @State private var selectedParties = ""
    @State private var selectedSmoke = ""
    @State private var selectedDrink = ""
    @State private var selectedAbout = ""
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
                VStack(spacing: 10) {
                    header
                    title
                    ZStack {
                        ForEach(cards) { card in
                            let index = cards.firstIndex { $0.id == card.id } ?? 0
                            SwipeCard(
                                step: card.step,
                                selectedRole:$selectedRole,
                                selectedCategory: $selectedCategory,
                                selectedShift: $selectedShift,
                                selectedFood:$selectedFood,
                                selectedParties:$selectedParties,
                                selectedSmoke:$selectedSmoke,
                                selectedDrink:$selectedDrink,
                                selectedAbout:$selectedAbout,
                                maxHeight: geo.size.height * 0.7
                            ) {
                                withAnimation(.spring()) {
                                    cards.removeAll { $0.id == card.id }
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
        .onAppear {
            if cards.isEmpty {
                cards = initialCards
            }
        }
    }
}
extension HomeView {
    var header: some View {
        HStack {
            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Spacer()
            HStack(spacing: 5) {
                Image("location")
                Text("Galway, Ireland")
                    .font(AppFont.manropeSemiBold(16))
            }
            Spacer()
            Image("bell")
        }
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
}
struct SwipeCard: View {
    let step: Int
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
    @Binding var selectedAbout: String
    let maxHeight: CGFloat
    let onRemove: () -> Void
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    private func swipe() {
        withAnimation(.spring()) {
            offset = CGSize(width: 600, height: 600)
            rotation = 30
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
                    selectedRole: $selectedRole,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 1:
                StepTwoView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 2:
                StepThreeView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 3:
                StepFourView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    selectedFood:$selectedFood,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 4:
                StepFiveView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    selectedFood:$selectedFood,
                    selectedParties:$selectedParties,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 5:
                StepSixView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    selectedFood:$selectedFood,
                    selectedParties:$selectedParties,
                    selectedSmoke:$selectedSmoke,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 6:
                StepSevenView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    selectedFood:$selectedFood,
                    selectedParties:$selectedParties,
                    selectedSmoke:$selectedSmoke,
                    selectedDrink:$selectedDrink,
                    onNext: swipe,
                    maxHeight: maxHeight)
            case 7:
                StepEightView(
                    selectedRole: $selectedRole,
                    selectedCategory: $selectedCategory,
                    selectedShift: $selectedShift,
                    selectedFood:$selectedFood,
                    selectedParties:$selectedParties,
                    selectedSmoke:$selectedSmoke,
                    selectedDrink:$selectedDrink,
                    selectedAbout:$selectedAbout,
                    onNext: swipe,
                    maxHeight: maxHeight)
            default:
                StepOneView(
                    selectedRole: $selectedRole,
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
struct StepOneView: View {
    @Binding var selectedRole: String
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
            selectedRole = title
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
                        selectedRole == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            print("Selected Role: \(selectedRole)")
            onNext()
        }) {
            HStack {
                Text("1/7")
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
                        selectedRole.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedRole.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepTwoView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    let onNext: () -> Void
    let maxHeight: CGFloat
    private let fields = [
        "Arts, Media & Creative",
        "Retail & E-Commerce",
        "Science & Research",
        "Finance & Accounting",
        "Marketing, Sales & Business Development",
        "Education & Training",
        "Hospitality, Travel & Tourism"
    ]
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    Text("What’s Your Professional Field?")
                        .font(AppFont.manropeBold(16))
                        .padding(.top, 50)
                    FlowLayout(spacing: 10) {
                        ForEach(fields, id: \.self) { field in
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
    private func CategoryButton(_ title: String) -> some View {
        Button {
            selectedCategory = title
        } label: {
            Text(title)
                .font(AppFont.manropeMedium(13))
                .foregroundColor(AppColors.Black)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    selectedCategory == title
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
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            onNext()
        }) {
            HStack {
                Text("2/7")
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
                        selectedCategory.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedCategory.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepThreeView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
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
            selectedShift = title
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
                        selectedShift == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            onNext()
        }) {
            HStack {
                Text("3/7")
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
                        selectedShift.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedShift.isEmpty)
        .padding(.bottom, 8)
    }
}

struct StepFourView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
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
            selectedFood = title
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
                        selectedFood == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            print("Selected Food: \(selectedFood)")
            onNext()
        }) {
            HStack {
                Text("4/7")
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
                        selectedFood.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedFood.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepFiveView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    let onNext: () -> Void
    let maxHeight: CGFloat
    private let fields = [
        "Not into it",
        "Sometimes",
        "Weekends",
        "Love it"
    ]
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Are You Into Parties?")
                        .font(AppFont.manropeBold(16))
                        .padding(.top, 50)
                    FlowLayout(spacing: 10) {
                        ForEach(fields, id: \.self) { field in
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
    private func PartyButton(_ title: String) -> some View {
        Button {
            selectedParties = title
        } label: {
            Text(title)
                .font(AppFont.manropeMedium(13))
                .foregroundColor(AppColors.Black)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    selectedParties == title
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
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            print("Selected Food: \(selectedFood)")
            print("Selected Parties: \(selectedParties)")
            onNext()
        }) {
            HStack {
                Text("5/7")
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
                        selectedParties.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedParties.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepSixView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
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
            selectedSmoke = title
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
                        selectedSmoke == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            print("Selected Food: \(selectedFood)")
            print("Selected Parties: \(selectedParties)")
            print("Selected Smoke: \(selectedSmoke)")
            onNext()
        }) {
            HStack {
                Text("6/7")
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
                        selectedSmoke.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedSmoke.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepSevenView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
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
            selectedDrink = title
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
                        selectedDrink == title
                        ? AppColors.primaryYellow
                        : AppColors.lightGray
                    )
            )
        }
    }
    var nextButton: some View {
        Button(action: {
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            print("Selected Food: \(selectedFood)")
            print("Selected Parties: \(selectedParties)")
            print("Selected Smoke: \(selectedSmoke)")
            print("Selected Drink: \(selectedDrink)")
            onNext()
        }) {
            HStack {
                Text("7/7")
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
                        selectedDrink.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedDrink.isEmpty)
        .padding(.bottom, 8)
    }
}
struct StepEightView: View {
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
    @Binding var selectedAbout: String
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
                    if selectedAbout.isEmpty {
                        Text("type here...")
                            .font(AppFont.manropeMedium(14))
                            .foregroundColor(.gray)
                            .padding(.top, 14)
                            .padding(.leading, 14)
                    }
                    MultilineTextView(text: $selectedAbout, isFocused: $isFocused)
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
            print("Selected Role: \(selectedRole)")
            print("Selected Category: \(selectedCategory)")
            print("Selected Shift: \(selectedShift)")
            print("Selected Food: \(selectedFood)")
            print("Selected Parties: \(selectedParties)")
            print("Selected Smoke: \(selectedSmoke)")
            print("Selected Drink: \(selectedDrink)")
            print("Selected About: \(selectedAbout)")
            onNext()
        }) {
            HStack {
                Text("7/7")
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
                        selectedAbout.isEmpty
                        ? Color.black.opacity(0.3)
                        : Color.black
                    )
            )
        }
        .disabled(selectedAbout.isEmpty)
        .padding(.bottom, 8)
    }
}

