import SwiftUI

// MARK: - Card Model
struct Card: Identifiable {
    let id = UUID()
    let step: Int
}

// MARK: - Home View
struct HomeView: View {
    @State private var cards: [Card] = []
    @State private var selectedOption = ""
    @State private var selectedDrink = ""
    
    private let initialCards: [Card] = [
        Card(step: 2), // StepThree
        Card(step: 1), // StepTwo
        Card(step: 0)  // StepOne
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
                
                VStack(spacing: 22) {
                    header
                    title
                    
                    ZStack {
                        ForEach(cards) { card in
                            let index = cards.firstIndex { $0.id == card.id } ?? 0
                            SwipeCard(
                                step: card.step,
                                selectedOption: $selectedOption,
                                selectedDrink: $selectedDrink,
                                maxHeight: geo.size.height * 0.90
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    cards.removeAll { $0.id == card.id }
                                }
                            }
                            .stacked(at: index, in: cards.count)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
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

// MARK: - Header & Title
private var header: some View {
    HStack {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: 44, height: 44)
            .foregroundColor(.black)

        Spacer()
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .foregroundColor(.yellow)
            Text("Galway, Ireland")
                .font(.headline)
        }
        Spacer()
        Image(systemName: "bell.fill")
            .frame(width: 40, height: 40)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
    }
    .padding(.horizontal)
}

private var title: some View {
    VStack(spacing: 6) {
        Text("Let’s match your lifestyle with the right people")
            .font(.title3.weight(.bold))
            .multilineTextAlignment(.center)

        Text("Share your lifestyle so others can instantly get your vibe.")
            .font(.subheadline)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal)
}

// MARK: - SwipeCard
struct SwipeCard: View {
    let step: Int
    @Binding var selectedOption: String
    @Binding var selectedDrink: String
    let maxHeight: CGFloat
    let onRemove: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var isSwiping = false
    @State private var selectedRole = "Working"

    private func swipe(_ right: Bool) {
        guard !isSwiping else { return }
        isSwiping = true

        withAnimation(.interpolatingSpring(stiffness: 50, damping: 12)) {
            offset = CGSize(width: right ? 600 : -600, height: 800)
            rotationAngle = right ? 90 : -90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            onRemove()
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                if step == 0 {
                    StepOneView(selectedRole: $selectedRole, onNext: { swipe(true) }, maxHeight: maxHeight)
                } else if step == 1 {
                    StepTwoView(selectedOption: $selectedOption, onNext: { swipe(true) }, maxHeight: maxHeight)
                } else if step == 2 {
                    StepThreeView(selectedDrink: $selectedDrink, onNext: { swipe(true) }, maxHeight: maxHeight)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: maxHeight)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.12), radius: 18, y: 12)
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(rotationAngle))
        .gesture(
            DragGesture()
                .onChanged {
                    guard !isSwiping else { return }
                    offset = $0.translation
                    rotationAngle = Double($0.translation.width / 25)
                }
                .onEnded {
                    guard !isSwiping else { return }
                    if $0.translation.width > 120 {
                        swipe(true)
                    } else if $0.translation.width < -120 {
                        swipe(false)
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotationAngle = 0
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Text("What best describes you?")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                HStack(spacing: 16) {
                    roleCard(title: "Student", icon: "book", isSelected: selectedRole == "Student") { selectedRole = "Student" }
                    roleCard(title: "Working", icon: "briefcase", isSelected: selectedRole == "Working") { selectedRole = "Working" }
                }
                Spacer(minLength: 0)
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .frame(minHeight: maxHeight - 180)
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    private func roleCard(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundColor(.black)
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? Color.yellow : Color.orange.opacity(0.2))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1))
        }
    }
}
struct StepTwoView: View {
    @Binding var selectedOption: String
    let onNext: () -> Void
    let maxHeight: CGFloat
    private let fields: [String] = [
        "Arts, Media & Creative",
        "Retail & E-Commerce",
        "Science & Research",
        "Finance & Accounting",
        "Marketing, Sales & Business Development",
        "Education & Training",
        "Hospitality, Travel & Tourism"
    ]
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("What’s Your Professional Field?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(fields, id: \.self) { field in
                        Option(title: field)
                    }
                }
                Spacer(minLength: 0)
                Button(action: onNext) {
                    HStack {
                        Text("2/7")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .frame(minHeight: maxHeight - 180)
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    private func Option(title: String) -> some View {
        Button {
            selectedOption = title
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 12)
                .background(selectedOption == title ? Color.yellow : Color.orange.opacity(0.2))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedOption == title ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1))
        }
        .gridCellColumns(title.count > 35 ? 2 : 1)
    }
}
// MARK: - StepThreeView
struct StepThreeView: View {
    @Binding var selectedDrink: String
    let onNext: () -> Void
    let maxHeight: CGFloat
    
    private let drinks: [String] = ["Coffee", "Tea", "Juice", "Water", "Smoothie"]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("What’s your favorite drink?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(drinks, id: \.self) { drink in
                        Button(action: {
                            selectedDrink = drink
                        }) {
                            Text(drink)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.horizontal, 12)
                                .background(selectedDrink == drink ? Color.yellow : Color.orange.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedDrink == drink ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1))
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                Button(action: onNext) {
                    HStack {
                        Text("3/7")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 56)
                    .background(selectedDrink.isEmpty ? Color.gray : Color.black)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .disabled(selectedDrink.isEmpty)
            }
            .frame(minHeight: maxHeight - 180)
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

// MARK: - Extensions
extension View {
    func stacked(at index: Int, in total: Int) -> some View {
        let position = CGFloat(total - index - 1)
        return self
            .scaleEffect(CGFloat(1) - position * CGFloat(0.04))
            .offset(y: position * CGFloat(12))
            .opacity(Double(CGFloat(1) - position * CGFloat(0.15)))
    }
}


