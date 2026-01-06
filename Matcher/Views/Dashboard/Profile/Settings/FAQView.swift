import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @StateObject private var FAQ = faqModel()
    @State private var expandedFAQ: Int?
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
                        ForEach(FAQ.faqs) { faq in
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
            FAQ.fetchFAQ()
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

