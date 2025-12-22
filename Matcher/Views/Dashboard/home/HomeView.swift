import SwiftUI
import MapKit
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
    @State private var roomOption = ""
    @State private var genderOption = ""
    @State private var Space = ""
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
    @State private var totalSteps: Int = 8
    @State private var showFinalStep = 0
    private var currentStep: Int {
        max(1, totalSteps - cards.count + 1)
    }
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
                    if showFinalStep == 1 {
                        NewStepView(
                            showFinalStep:$showFinalStep,
                            selectedRole: $selectedRole,
                            selectedCategory: $selectedCategory,
                            selectedShift: $selectedShift,
                            selectedFood:$selectedFood,
                            selectedParties:$selectedParties,
                            selectedSmoke:$selectedSmoke,
                            selectedDrink:$selectedDrink,
                            selectedAbout:$selectedAbout,
                            roomOption: $roomOption,
                            onNext: next)
                    }else if showFinalStep == 2 {
                        GenderStepView(
                                showFinalStep:$showFinalStep,
                                selectedRole: $selectedRole,
                                selectedCategory: $selectedCategory,
                                selectedShift: $selectedShift,
                                selectedFood:$selectedFood,
                                selectedParties:$selectedParties,
                                selectedSmoke:$selectedSmoke,
                                selectedDrink:$selectedDrink,
                                selectedAbout:$selectedAbout,
                                roomOption: $roomOption,
                                genderOption: $genderOption,
                                onNext: next)
                    }else if showFinalStep == 3 {
                        SpaceView(
                                showFinalStep:$showFinalStep,
                                selectedRole: $selectedRole,
                                selectedCategory: $selectedCategory,
                                selectedShift: $selectedShift,
                                selectedFood:$selectedFood,
                                selectedParties:$selectedParties,
                                selectedSmoke:$selectedSmoke,
                                selectedDrink:$selectedDrink,
                                selectedAbout:$selectedAbout,
                                roomOption: $roomOption,
                                genderOption: $genderOption,
                                onNext: next)
                    } else {
                        header
                        title
                        ZStack {
                            ForEach(cards) { card in
                                let index = cards.firstIndex { $0.id == card.id } ?? 0
                                SwipeCard(
                                    step: card.step,
                                    currentStep: currentStep,
                                    totalSteps: totalSteps,
                                    selectedRole: $selectedRole,
                                    selectedCategory: $selectedCategory,
                                    selectedShift: $selectedShift,
                                    selectedFood: $selectedFood,
                                    selectedParties: $selectedParties,
                                    selectedSmoke: $selectedSmoke,
                                    selectedDrink: $selectedDrink,
                                    selectedAbout: $selectedAbout,
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
        .onAppear {
            cards = initialCards
        }
        .onChange(of: selectedRole) {
            rebuildCards()
        }
    }
    private func next() {
    }
    private func rebuildCards() {
        if selectedRole == "Student" {
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
    struct SwipeCard: View {
        let step: Int
        let currentStep: Int
        let totalSteps: Int
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
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 1:
                    if selectedRole != "Student" {
                        StepTwoView(
                            selectedRole: $selectedRole,
                            selectedCategory: $selectedCategory,
                            currentStep: currentStep,
                            totalSteps: totalSteps,
                            onNext: swipe,
                            maxHeight: maxHeight)
                    }
                case 2:
                    StepThreeView(
                        selectedRole: $selectedRole,
                        selectedCategory: $selectedCategory,
                        selectedShift: $selectedShift,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 3:
                    StepFourView(
                        selectedRole: $selectedRole,
                        selectedCategory: $selectedCategory,
                        selectedShift: $selectedShift,
                        selectedFood:$selectedFood,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                case 4:
                    StepFiveView(
                        selectedRole: $selectedRole,
                        selectedCategory: $selectedCategory,
                        selectedShift: $selectedShift,
                        selectedFood:$selectedFood,
                        selectedParties:$selectedParties,
                        currentStep: currentStep,
                        totalSteps: totalSteps,
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
                        currentStep: currentStep,
                        totalSteps: totalSteps,
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
                        currentStep: currentStep,
                        totalSteps: totalSteps,
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
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: swipe,
                        maxHeight: maxHeight)
                default:
                    StepOneView(
                        selectedRole: $selectedRole,
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
    @Binding var selectedRole: String
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
    let currentStep: Int
    let totalSteps: Int
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
    let currentStep: Int
    let totalSteps: Int
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
struct NewStepView: View {
    @Binding var showFinalStep: Int
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
    @Binding var selectedAbout: String
    @Binding var roomOption: String
    let onNext: () -> Void
    var body: some View {
        VStack {
            header
            Spacer().frame(height: 40)
            title
            Spacer().frame(height: 30)
            VStack(spacing: 16) {
                OptionButton(title: "Yes, I have a room to share", isSelected: roomOption == "Yes") {
                    roomOption = "Yes"
                }
                OptionButton(title: "No, I’m looking for a room", isSelected: roomOption == "No") {
                    roomOption = "No"
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
                print("Selected Role: \(selectedRole)")
                print("Selected Category: \(selectedCategory)")
                print("Selected Shift: \(selectedShift)")
                print("Selected Food: \(selectedFood)")
                print("Selected Parties: \(selectedParties)")
                print("Selected Smoke: \(selectedSmoke)")
                print("Selected Drink: \(selectedDrink)")
                print("Selected About: \(selectedAbout)")
                print("Selected room Option: \(roomOption)")
                showFinalStep = 2
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            roomOption.isEmpty
                            ? Color.black.opacity(0.3)
                            : Color.black
                        )
                        .frame(height: 56)
                    Text("Next")
                        .font(AppFont.manropeMedium(16))
                        .foregroundColor(.white)
                }
            }.disabled(roomOption.isEmpty)

        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
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
    @Binding var showFinalStep: Int
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
    @Binding var selectedAbout: String
    @Binding var roomOption: String
    @Binding var genderOption: String
    let onNext: () -> Void
    private let options = ["Male", "Female", "Non-binary", "Open to all"]
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
            Button(action: {
                print("Selected Role: \(selectedRole)")
                print("Selected Category: \(selectedCategory)")
                print("Selected Shift: \(selectedShift)")
                print("Selected Food: \(selectedFood)")
                print("Selected Parties: \(selectedParties)")
                print("Selected Smoke: \(selectedSmoke)")
                print("Selected Drink: \(selectedDrink)")
                print("Selected About: \(selectedAbout)")
                print("Selected room Option: \(roomOption)")
                print("Selected gender Option: \(genderOption)")
                showFinalStep = 3
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            genderOption.isEmpty
                            ? Color.black.opacity(0.3)
                            : Color.black
                        )
                        .frame(height: 56)
                    Text("Next")
                        .font(AppFont.manropeMedium(16))
                        .foregroundColor(.white)
                }
            }
            .disabled(genderOption.isEmpty)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
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
            ForEach(options, id: \.self) { option in
                GenderOptionCard(
                    title: option,
                    isSelected: genderOption == option
                ) {
                    genderOption = option
                }
            }
        }
        .padding(.horizontal, 20)
    }
    struct GenderOptionCard: View {
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

struct SpaceView: View {
    @Binding var showFinalStep: Int
    @Binding var selectedRole: String
    @Binding var selectedCategory: String
    @Binding var selectedShift: String
    @Binding var selectedFood: String
    @Binding var selectedParties: String
    @Binding var selectedSmoke: String
    @Binding var selectedDrink: String
    @Binding var selectedAbout: String
    @Binding var roomOption: String
    @Binding var genderOption: String
    let onNext: () -> Void
    @State private var selectedSpaceType = "Single Room"
    @State private var selectedRoommates = 1
    @State private var rent = "5000"
    @State private var selectedFurnishing = "Fully Furnished"
    @State private var selectedGender = "Male"
    @State private var selectedAmenities: Set<String> = []
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.6782, longitude: -73.9442),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    struct Amenity: Identifiable {
        let id = UUID()
        let title: String
        let image: String
    }
    var body: some View {
        VStack(spacing: 20) {
            header
            ScrollView(showsIndicators: false) {
                title
                VStack(alignment: .leading, spacing: 20) {
                    photosSection.padding(.top,10)
                    sectionTitle("Space Type")
                    segmented(
                        options: ["Single Room", "1 BHK", "2 BHK", "3 BHK"],
                        selected: $selectedSpaceType
                    )
                    sectionTitle("How Many Roommates Do You Want?")
                    roommatesSection
                    sectionTitle("Rent Split (Per Person)")
                    rentField
                    sectionTitle("Furnishing")
                    segmented(
                        options: ["Fully Furnished", "Semi Furnished", "Unfurnished"],
                        selected: $selectedFurnishing
                    )
                    sectionTitle("Amenities")
                    StepAmenitiesView(selectedAmenities: $selectedAmenities)
                    sectionTitle("Who Would You Like To Live With?")
                    segmented(
                        options: ["Male", "Female", "Non-binary", "Open to all"],
                        selected: $selectedGender
                    )
                    mapSection
                    nextButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Add At Least 5 Clear Photos Of Your Space.")
                .font(AppFont.manropeMedium(14))
            HStack(spacing: 12) {
                dashedPhoto(size: 165)
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        dashedPhoto(size: 80)
                        dashedPhoto(size: 80)
                    }
                    HStack(spacing: 12) {
                        dashedPhoto(size: 80)
                        dashedPhoto(size: 80)
                    }
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
        TextField("5000", text: $rent)
            .keyboardType(.numberPad)
            .padding()
            .background(AppColors.backgroundWhite)
            .cornerRadius(12)
    }
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location : Brooklyn, New York, NY 11226")
                .font(AppFont.manropeMedium(14))
            Map(position: $cameraPosition)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    .padding(),
                    alignment: .bottom
                )
        }
    }
    private var nextButton: some View {
        HStack(spacing: 12) {
            Button {
                showFinalStep -= 1
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.primaryYellow)
                    .frame(width: 56, height: 56)
                    .overlay(Image("dobleBack"))
            }
            Button {
                debugPrintData()
                showFinalStep = 3
                onNext()
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(genderOption.isEmpty ? AppColors.Black.opacity(0.3) : AppColors.Black)
                    .frame(height: 56)
                    .overlay(
                        Text("Next")
                            .font(AppFont.manropeMedium(16))
                            .foregroundColor(AppColors.backgroundWhite)
                    )
            }
            .disabled(genderOption.isEmpty)
        }
    }
    private var header: some View {
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
        .padding(.leading,2)
        .padding(.trailing,2)
    }
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppFont.manropeSemiBold(15))
    }
    func dashedPhoto(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .frame(width: size, height: size)
            Circle()
                .fill(AppColors.primaryYellow)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                )
        }
    }
    func segmented(options: [String], selected: Binding<String>) -> some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isSelected = selected.wrappedValue == option
                Text(option)
                    .font(AppFont.manropeMedium(14))
                    .foregroundColor(isSelected ? AppColors.Black : AppColors.backgroundWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isSelected ? AppColors.primaryYellow : AppColors.Black)
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
                            selected.wrappedValue = option
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
    struct StepAmenitiesView: View {
        @Binding var selectedAmenities: Set<String>
        private let amenities: [Amenity] = [
            Amenity(title: "AC", image: "ac"),
            Amenity(title: "Wi-Fi", image: "wifi"),
            Amenity(title: "Parking", image: "parking"),
            Amenity(title: "Kitchen", image: "kitchen"),
            Amenity(title: "Washing Machine", image: "washing"),
            Amenity(title: "Water 24x7", image: "water"),
            Amenity(title: "Balcony", image: "balcony"),
            Amenity(title: "Pet Friendly", image: "pet")
        ]
        var body: some View {
            ScrollView {
                FlowLayout(spacing: 10) {
                    ForEach(amenities) { item in
                        AmenityButton(item)
                    }
                }
                .padding(.top, 5)
            }
        }
        private func AmenityButton(_ item: Amenity) -> some View {
            Button {
                if selectedAmenities.contains(item.title) {
                    selectedAmenities.remove(item.title)
                } else {
                    selectedAmenities.insert(item.title)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(item.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text(item.title)
                        .font(AppFont.manropeMedium(13))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    selectedAmenities.contains(item.title)
                    ? AppColors.primaryYellow
                    : AppColors.backgroundClear
                )
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    private func debugPrintData() {
            print("Selected Role:", selectedRole)
            print("Selected Category:", selectedCategory)
            print("Selected Shift:", selectedShift)
            print("Selected Food:", selectedFood)
            print("Selected Parties:", selectedParties)
            print("Selected Smoke:", selectedSmoke)
            print("Selected Drink:", selectedDrink)
            print("Selected About:", selectedAbout)
            print("Selected Room Option:", roomOption)
            print("Selected Gender Option:", genderOption)
            print("Selected Space Type:", selectedSpaceType)
            print("Selected Roommates:", selectedRoommates)
            print("Rent:", rent)
            print("Selected Furnishing:", selectedFurnishing)
            print("Selected Gender:", selectedGender)
            print("Selected Amenities:", selectedAmenities)
    }
}
