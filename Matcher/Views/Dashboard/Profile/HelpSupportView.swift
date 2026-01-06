import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var message: String = ""
    @FocusState private var isEditorFocused: Bool

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
                    VStack(spacing: 24) {
                        Text("Explain your problem")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 40)
                        textEditorView
                        submitButton
                    }
                    .padding(.horizontal, 20)
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
            Text("Help and Supports")
                .font(AppFont.manropeSemiBold(16))
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    private var textEditorView: some View {
        ZStack(alignment: .topLeading) {
            if message.isEmpty && !isEditorFocused {
                Text("type here...")
                    .foregroundColor(.gray)
                    .padding(.top, 14)
                    .padding(.leading, 12)
            }
            TextEditor(text: $message)
                .focused($isEditorFocused)
                .padding(8)
                .scrollContentBackground(.hidden)
        }
        .background(Color.white)
        .cornerRadius(12)
        .frame(height: 180)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    private var submitButton: some View {
        Button {
        } label: {
            Text("Submit")
                .font(AppFont.manropeSemiBold(14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(14)
        }
        .padding(.top, 20)
    }
}
