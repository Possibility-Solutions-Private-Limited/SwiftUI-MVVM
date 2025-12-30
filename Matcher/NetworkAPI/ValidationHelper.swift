import Foundation
import SwiftUI

final class ValidationHelper: ObservableObject {
    // MARK: - Toast State
    @Published var showToast: Bool = false
    @Published var validationMessage: String = ""
    // MARK: - Show Toast
    func showValidation(_ message: String) {
        validationMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
    // MARK: - Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    // MARK: - Password Validation
    func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
    // MARK: - Mobile Validation
    func isValidMobile(_ mobile: String) -> Bool {
        let regex = #"^[0-9]{10}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: mobile)
    }
    // MARK: - Name Validation
    func isValidName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    // MARK: - OTP Validation
    func isValidOTP(_ otp: String) -> Bool {
        let regex = #"^[0-9]{6}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: otp)
    }
    // MARK: - Empty Field
    func isNotEmpty(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
struct AppFont {
    // MARK: - Extra Light
    static func manropeExtraLight(_ size: CGFloat) -> Font {
        .custom("Manrope-ExtraLight", size: size)
    }
    // MARK: - Light
    static func manropeLight(_ size: CGFloat) -> Font {
        .custom("Manrope-Light", size: size)
    }
    // MARK: - Regular
    static func manrope(_ size: CGFloat) -> Font {
        .custom("Manrope-Regular", size: size)
    }
    // MARK: - Medium
    static func manropeMedium(_ size: CGFloat) -> Font {
        .custom("Manrope-Medium", size: size)
    }
    // MARK: - SemiBold
    static func manropeSemiBold(_ size: CGFloat) -> Font {
        .custom("Manrope-SemiBold", size: size)
    }
    // MARK: - Bold
    static func manropeBold(_ size: CGFloat) -> Font {
        .custom("Manrope-Bold", size: size)
    }
    // MARK: - ExtraBold
    static func manropeExtraBold(_ size: CGFloat) -> Font {
        .custom("Manrope-ExtraBold", size: size)
    }
}

struct AppColors {
    static let primaryYellow = Color.yellow.opacity(0.9)
    static let borderGray = Color.gray.opacity(0.3)
    static let backgroundWhite = Color.white
    static let backgroundClear = Color.clear
    static let Black = Color.black
    static let Gray = Color.gray
    static let lightGray = Color(hex: "#F4F4E8")
    static let ExtralightGray = Color(hex: "#CDCDCD")

}
struct ValidationMessages {
    static let emailEmpty = "Please enter your email address."
    static let emailInvalid = "Please enter a valid email address."
    static let passwordEmpty = "Please enter your password."
    static let passwordTooShort = "Password must be at least 6 characters long."
    static let phoneEmpty = "Please enter your email address."
    static let phoneInvalid = "Please enter your valid phone number."
    static let firstNameEmpty = "Please enter your first name."
    static let lastNameEmpty = "Please enter your last name."
    static let confirmPasswordEmpty = "Please confirm your password."
    static let passwordMismatch = "Passwords do not match."
}
extension Color {
    static let splashTop = Color(hex: "#F4F4F4")
    static let splashBottom = Color(hex: "#FFE7A3")
    static let primaryYellow = Color(hex: "#FFE55C")
    static let textPrimary = Color.black
    static let derkYellow = Color.yellow.opacity(0.08)
    static let lightYellow = Color.yellow.opacity(0.05)
    static let cardBackground = Color.white
}
extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
struct FlowLayout: Layout {
    var spacing: CGFloat = 12
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(
            top: 12, left: 12, bottom: 20, right: 12
        )
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = .done
        textView.inputAccessoryView = nil
        textView.delegate = context.coordinator
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        DispatchQueue.main.async {
            if isFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: MultilineTextView
        init(_ parent: MultilineTextView) {
            self.parent = parent
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.setContentOffset(.zero, animated: false)
        }
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                DispatchQueue.main.async {
                    self.parent.isFocused = false
                }
                return false
            }
            return true
        }
    }
}
struct KeyboardDoneTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        textField.text = text         // 👈 SHOW DEFAULT
        textField.delegate = context.coordinator
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        ]
        textField.inputAccessoryView = toolbar
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text       // 👈 KEEP SYNCED
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KeyboardDoneTextField
        init(_ parent: KeyboardDoneTextField) { self.parent = parent }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
func calculateAge(_ dob: String?) -> Int {
    guard let dob = dob else { return 0 }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    guard let birthDate = formatter.date(from: dob) else { return 0 }
    let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
    return ageComponents.year ?? 0
}
extension String {
    func cleanDecimal() -> String {
        guard let number = Double(self) else { return self }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
}
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    var range: ClosedRange<Double>
    private let barHeight: CGFloat = 4
    private let thumbSize: CGFloat = 28
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: barHeight)
                Capsule()
                    .fill(AppColors.primaryYellow)
                    .frame(width: selectedWidth(width), height: barHeight)
                    .offset(x: minX(width))
                Circle()
                    .fill(AppColors.primaryYellow)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: minX(width) - thumbSize / 2)
                    .gesture(
                        DragGesture().onChanged { value in
                            let new = valueToRange(x: value.location.x, width: width)
                            minValue = min(max(new, range.lowerBound), maxValue)
                        }
                    )
                Circle()
                    .fill(AppColors.primaryYellow)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: maxX(width) - thumbSize / 2)
                    .gesture(
                        DragGesture().onChanged { value in
                            let new = valueToRange(x: value.location.x, width: width)
                            maxValue = max(min(new, range.upperBound), minValue)
                        }
                    )
            }
        }
    }
    private func minX(_ width: CGFloat) -> CGFloat {
        let percent = (minValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        return percent * width
    }
    private func maxX(_ width: CGFloat) -> CGFloat {
        let percent = (maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        return percent * width
    }
    private func selectedWidth(_ width: CGFloat) -> CGFloat {
        maxX(width) - minX(width)
    }
    private func valueToRange(x: CGFloat, width: CGFloat) -> Double {
        let pos = max(0, min(x, width))
        let percent = Double(pos / width)
        return range.lowerBound + percent * (range.upperBound - range.lowerBound)
    }
}


