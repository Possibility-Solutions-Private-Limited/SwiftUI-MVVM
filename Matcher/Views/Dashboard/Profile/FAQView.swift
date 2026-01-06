import SwiftUI

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var faqs: [FAQ] = [
        FAQ(question: "What Does Lorem Mean?",
            answer: "Lorem Ipsum Dolor Sit Amet, Consectetur Adipisici Elit…’ (Complete Text) Is Dummy Text That Is Not Meant To Mean Anything. It Is Used As A Placeholder In Magazine Layouts, For Example, In Order To Give An Impression Of The Finished Document."),
        FAQ(question: "Why Is My Verification Failing?", answer: "1"),
        FAQ(question: "My App Is Running Slow. What Can I Do?", answer: "2"),
        FAQ(question: "How Do I Report Someone?", answer: "3"),
        FAQ(question: "How Do I Recover A Deleted Chat?", answer: "4"),
        FAQ(question: "How Do I Enable Dark Mode?", answer: "5"),
        FAQ(question: "Can I Use The App On Multiple Devices?", answer: "6"),
        FAQ(question: "How Do I Update The App?", answer: "7"),
        FAQ(question: "Why Can’t I Upload Images?", answer: "8"),
        FAQ(question: "How Do I Delete My Account?", answer: "9")
    ]
    @State private var expandedFAQ: UUID?
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.splashTop, .splashBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 24) {
                headerView
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(faqs) { faq in
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        if expandedFAQ == faq.id {
                                            expandedFAQ = nil
                                        } else {
                                            expandedFAQ = faq.id
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(faq.question)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: expandedFAQ == faq.id ? "minus" : "plus")
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                }
                                if expandedFAQ == faq.id && !faq.answer.isEmpty {
                                    Text(faq.answer)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .padding([.horizontal, .bottom])
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                                
                                Divider()
                                    .background(Color.black.opacity(0.8))
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
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
            Text("FAQs")
                .font(AppFont.manropeSemiBold(16))
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

