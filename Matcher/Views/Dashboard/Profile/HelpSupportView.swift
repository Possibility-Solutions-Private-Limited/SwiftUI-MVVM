import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var message: String = ""
    @FocusState private var isEditorFocused: Bool
    @StateObject private var validator = ValidationHelper()
    @StateObject private var HELP = HelpModel()
    @State private var isUploading = false
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
        .toast(message: validator.validationMessage, isPresented: $validator.showToast)
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
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isEditorFocused = false
                        }
                        .foregroundColor(.black)
                    }
                }
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
        Button(action: Helps) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.Black)
                    .frame(height: 50)
                HStack(spacing: 8) {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .black)
                            )
                    }
                    Text("Submit")
                        .font(AppFont.manropeMedium(16))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .allowsHitTesting(!isUploading)
        .opacity(isUploading ? 0.7 : 1)
    }
    func Helps() {
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validator.showValidation(ValidationMessages.helpEmpty)
                return
        }
        isUploading = true
        let param: [String: Any] = [
            "problem": message
        ]
        HELP.HelpAPI(param: param) { response in
            if let response = response {
                if response.success {
                    validator.showValidation(response.message ?? "")
                    validator.showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                } else {
                    validator.showValidation(response.message ?? "")
                    validator.showToast = true
                    isUploading = false
                }
            } else {
                validator.showValidation("Something went wrong")
                validator.showToast = true
                isUploading = false
            }
        }
    }
}
