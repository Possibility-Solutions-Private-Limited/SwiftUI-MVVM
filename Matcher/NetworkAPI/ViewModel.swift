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
class SocialloginModel: ObservableObject {
    func SocialloginAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        print(param)
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.Sociallogin,
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
    func SignUpWithImages(images: [MultipartImage],params: [String: Any],completion: @escaping (UserModel?) -> Void) {
        NetworkManager.shared.uploadMultipart(
            endpoint: APIConstants.Endpoints.StepOne,
            parameters: params,
            images: images
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
final class UserSelections: ObservableObject {
    @Published var selectedRole = ""
    @Published var selectedCategory: Int?
    @Published var selectedShift = ""
    @Published var selectedFood = ""
    @Published var selectedParties: Int?
    @Published var selectedSmoke = ""
    @Published var selectedDrink = ""
    @Published var selectedAbout = ""
    @Published var roomOption = ""
    @Published var genderOption:Int?
}
class BasicModel: ObservableObject {
    @Published var roomTypes: [OptionItem] = []
    @Published var amenities: [OptionItem] = []
    @Published var furnishTypes: [OptionItem] = []
    @Published var genders: [OptionItem] = []
    @Published var professionalFields: [OptionItem] = []
    @Published var partyPreferences: [OptionItem] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    func fetchBasicData() {
        isLoading = true
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.BasicData,
            method: "GET",
            parameters: nil
        ) { (result: Result<BasicDataModel, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    let data = response.data
                    self.roomTypes.append(contentsOf: data.room.roomType)
                    self.amenities.append(contentsOf: data.room.amenities)
                    self.furnishTypes.append(contentsOf: data.room.furnishType)
                    self.genders.append(contentsOf: data.gender)
                    self.professionalFields.append(contentsOf: data.professionalField)
                    self.partyPreferences.append(contentsOf: data.intoParty)
                    print("✅ Basic Data Loaded Successfully")

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Error fetching basic data:", error.localizedDescription)
                }
            }
        }
    }
}
class StepTwoModel: ObservableObject {
    func StepTwoAPI(param: [String: Any], completion: @escaping (UserModel?) -> Void) {
        NetworkManager.shared.makeRequest(
            endpoint: APIConstants.Endpoints.StepTwo,
            method: "POST",
            parameters: param,
            completion: { (result: Result<UserModel, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                    print("STEP-TWO Success: \(response)")
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
class RoomModel: ObservableObject {
    func RoomWithImages(
        images: [MultipartImage],
        params: [String: Any] = [:],
        amenities: [Int] = [],
        completion: @escaping (Bool, String?) -> Void
    ) {
        var multipartParams = params
        multipartParams.removeValue(forKey: "amenities")
        NetworkManager.shared.uploadMultiparts(
            endpoint: APIConstants.Endpoints.AddRoom,
            parameters: multipartParams,
            amenities: amenities,
            images: images
        ) { (result: Result<SpaceModel, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Add-Room Success:", response)
                    if response.success == true {
                        completion(true, response.message)
                    } else {
                        completion(false, response.message)
                    }
                case .failure(let error):
                    print("Add-Room Error:", error.localizedDescription)
                    completion(false, error.localizedDescription)
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



