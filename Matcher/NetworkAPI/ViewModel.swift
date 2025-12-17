import Foundation
class LoginModel: ObservableObject {
    func LoginAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        print(param)
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.login,
            method: "POST",
            parameters: param
        ) { (result: Result<UserModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                print("LOGIN Success: \(response)")
                if response.success {
                    completion(response)
                } else {
                    completion(response)
                }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
}
class SignUpModel: ObservableObject {
    func SignUpAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        print(param)
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.SignUp,
            method: "POST",
            parameters: param
        ) { (result: Result<UserModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                print("SIGNUP Success: \(response)")
                if response.success {
                    completion(response)
                } else {
                    completion(response)
                }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
}
class ProfileModel: ObservableObject {
    func SignUpWithImages(
        images: [MultipartImage],
        params: [String: Any] = [:],
        completion: @escaping (Bool, String?) -> Void
    ) {
        NetworkManager.shared.uploadMultipart(
            endpoint: APIConstants.Endpoints.StepOne,
            parameters: params,
            images: images
        ) { (result: Result<UserModel?, Error>) in

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("SIGNUP Success:", response ?? "")
                    if ((response?.success) != nil) {
                        completion(true, response?.message)
                    } else {
                        completion(false, response?.message)
                    }
                case .failure(let error):
                    print("SIGNUP Error:", error.localizedDescription)
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
class VerifyModel: ObservableObject {
    func VerifyAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.verifyOTP,
            method: "POST",
            parameters: param,
            completion: { (result: Result<UserModel, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                    print("VERIFY Success: \(response)")
                    if response.success {
                        completion(response)
                    } else {
                        completion(response)
                    }
                    case .failure(_):
                        completion(nil)
                    }
                }
            }
        )
    }
}
class ForgotModel: ObservableObject {
    func ForgotAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        print(param)
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.sendOTP,
            method: "POST",
            parameters: param
        ) { (result: Result<UserModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                print("SIGNUP Success: \(response)")
                if response.success {
                    completion(response)
                } else {
                    completion(response)
                }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
}
class VerifyForgotModel: ObservableObject {
    func VerifyForgotAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.verifyForgotOTP,
            method: "POST",
            parameters: param,
            completion: { (result: Result<UserModel, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                    print("VERIFY-Forgot Success: \(response)")
                    if response.success {
                        completion(response)
                    } else {
                        completion(response)
                    }
                    case .failure(_):
                        completion(nil)
                    }
                }
            }
        )
    }
}
class ChangeForgotModel: ObservableObject {
    func ChangeForgotAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        print(param)
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.ChangePassword,
            method: "POST",
            parameters: param
        ) { (result: Result<UserModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                print("CHANGE PASSWORD Success: \(response)")
                if response.success {
                    completion(response)
                } else {
                    completion(response)
                }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
}
class ChatsModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var users: [Users] = []
    func fetchChat() {
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.chatUser, method: "GET",
            parameters: nil
        ) { (result: Result<ChatModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Chat: \(response)")
                    self.chats = response.data.data
                    self.users = response.Users ?? []
                case .failure(let error):
                    print("Error fetching deductions: \(error.localizedDescription)")
                }
            }
        }
    }
}
class ChatHistoryModel: ObservableObject {
    @Published var messages: [Message] = []
    func fetchChatHistory(chatId: String) {
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.chatlist, method: "POST",
            parameters: ["chat_id": chatId]
        ) { (result: Result<MessageModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Attandance: \(response)")
                    self.messages = response.data 
                case .failure(let error):
                    print("Error fetching deductions: \(error.localizedDescription)")
                }
            }
        }
    }
}



