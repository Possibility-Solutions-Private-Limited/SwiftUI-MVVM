import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    private let baseURL = APIConstants.baseURL
    func makeRequest<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let token = KeychainHelper.shared.get(forKey: "access_token")
        var urlString = baseURL + endpoint
        if method == "GET", let parameters = parameters {
            let query = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(query)"
        }
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if method != "GET" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            } catch {
                completion(.failure(error))
                return
            }
        }
        print(request)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Decode Error:", String(data: data, encoding: .utf8) ?? "")
                completion(.failure(error))
            }
        }.resume()
    }
    func makeRequestAsync<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any]?
    ) async throws -> T {
        
        let urlString = APIConstants.baseURL + endpoint
        var components = URLComponents(string: urlString)!
        
        if method == "GET", let params = parameters {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
    func uploadMultipart<T: Decodable>(
        endpoint: String,
        parameters: [String: Any],
        images: [MultipartImage]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = KeychainHelper.shared.get(forKey: "access_token")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var body = Data()
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        if let images = images {
            for image in images {
                if let imageData = image.data {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.filename)\"\r\n")
                    body.appendString("Content-Type: image/jpeg\r\n\r\n")
                    body.append(imageData)
                    body.appendString("\r\n")
                }
            }
        }
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "EMPTY_RESPONSE", code: -1)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Multipart decode error:", String(data: data, encoding: .utf8) ?? "")
                completion(.failure(error))
            }
        }.resume()
    }
    func uploadMultiparts<T: Decodable>(
        endpoint: String,
        parameters: [String: Any],
        amenities: [Int]? = nil, // NEW: amenities array
        images: [MultipartImage]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        print(url)
        request.httpMethod = "POST"
        if let token = KeychainHelper.shared.get(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        if let amenities = amenities {
            for id in amenities {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"amenities[]\"\r\n\r\n")
                body.appendString("\(id)\r\n")
            }
        }
        if let images = images {
            for image in images {
                if let imageData = image.data {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.filename)\"\r\n")
                    body.appendString("Content-Type: image/jpeg\r\n\r\n")
                    body.append(imageData)
                    body.appendString("\r\n")
                }
            }
        }
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "EMPTY_RESPONSE", code: -1)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Multipart decode error:", String(data: data, encoding: .utf8) ?? "")
                completion(.failure(error))
            }
        }.resume()
    }
}
struct MultipartImage {
    let key: String
    let filename: String
    let data: Data?
}
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
