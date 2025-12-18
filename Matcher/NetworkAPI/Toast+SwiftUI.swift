import SwiftUI
import Toast

extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        overlay(
            VStack {
                Spacer().frame(height: 65)
                ToastView(message: message, show: isPresented)
                    .allowsHitTesting(false)
                Spacer()
            },
            alignment: .top
        )
    }
}
struct ToastView: UIViewRepresentable {
    let message: String
    @Binding var show: Bool

    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        guard show else { return }

        var style = ToastStyle()
        style.backgroundColor = .black.withAlphaComponent(0.8)
        style.messageColor = .white
        uiView.makeToast(
            message,
            duration: 2.0,
            position: .top,
            style: style
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            show = false
        }
    }
}

// MARK: - Font Helper
extension UIFont {
    static func manrope(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .medium:
            fontName = "Manrope-Medium"
        case .semibold:
            fontName = "Manrope-SemiBold"
        case .bold:
            fontName = "Manrope-Bold"
        default:
            fontName = "Manrope-Regular"
        }
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
// MARK: - PhoneTextField
struct PhoneTextField: UIViewRepresentable {
    @Binding var text: String
    var onNext: () -> Void
    var onCancel: () -> Void
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.font = UIFont.manrope(13)
        textField.textColor = .black
        textField.tintColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter Mobile Number",
            attributes: [
                .foregroundColor: UIColor.black.withAlphaComponent(0.7),
                .font: UIFont.manrope(13)
            ]
        )
        textField.delegate = context.coordinator
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = .white
        toolbar.isTranslucent = false
        let cancel = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.cancelTapped)
        )
        cancel.setTitleTextAttributes([
            .font: UIFont.manrope(15, weight: .medium),
            .foregroundColor: UIColor.black
        ], for: .normal)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next = UIBarButtonItem(
            title: "Next",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.nextTapped)
        )
        next.setTitleTextAttributes([
            .font: UIFont.manrope(15, weight: .semibold),
            .foregroundColor: UIColor.black
        ], for: .normal)
        toolbar.items = [cancel, spacer, next]
        textField.inputAccessoryView = toolbar
        return textField
    }
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: PhoneTextField
        init(_ parent: PhoneTextField) { self.parent = parent }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        @objc func cancelTapped() {
            parent.onCancel()
            dismissKeyboard()
        }
        @objc func nextTapped() {
            parent.onNext()
        }
        private func dismissKeyboard() {
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        }
    }
}
struct NoAssistantTextField: UIViewRepresentable {

    enum FieldType {
        case Email
        case Password
        case Normal
    }

    @Binding var text: String
    @Binding var isSecure: Bool
    var placeholder: String
    var fieldType: FieldType
    var returnKeyType: UIReturnKeyType = .next
    var onCommit: (() -> Void)? = nil

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        configure(tf, context: context)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Sync text
        if uiView.text != text {
            uiView.text = text
        }
        // Sync secure entry for password
        if fieldType == .Password,
           uiView.isSecureTextEntry != isSecure {
            let currentText = uiView.text
            uiView.isSecureTextEntry = isSecure
            uiView.text = currentText
        }
    }

    private func configure(_ tf: UITextField, context: Context) {
        tf.font = UIFont.manrope(13)
        tf.textColor = .black
        tf.delegate = context.coordinator
        tf.returnKeyType = returnKeyType

        // Disable autocorrect, spell checking, and smart features
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.smartQuotesType = .no
        tf.smartDashesType = .no
        tf.smartInsertDeleteType = .no

        // Disable QuickType / autofill toolbar
        tf.inputAssistantItem.leadingBarButtonGroups = []
        tf.inputAssistantItem.trailingBarButtonGroups = []

        // Placeholder styling
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        )

        // Critical: disable iOS autofill & strong password suggestions
        DispatchQueue.main.async {
            tf.textContentType = nil
            if #available(iOS 12.0, *) {
                tf.passwordRules = nil
            }
        }

        switch fieldType {
        case .Email:
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
            tf.isSecureTextEntry = false

        case .Password:
            tf.keyboardType = .default
            tf.autocapitalizationType = .none
            tf.isSecureTextEntry = isSecure

        case .Normal:
            tf.keyboardType = .default
            tf.autocapitalizationType = .none
            tf.isSecureTextEntry = false
        }

        // Handle Return/Next
        tf.addTarget(
            context.coordinator,
            action: #selector(Coordinator.editingDidEndOnExit),
            for: .editingDidEndOnExit
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: NoAssistantTextField
        init(_ parent: NoAssistantTextField) { self.parent = parent }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        @objc func editingDidEndOnExit() {
            parent.onCommit?()
        }
    }
}
