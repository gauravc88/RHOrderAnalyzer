import Foundation

public typealias AuthResponse = (String?, Error?) -> Void
public class Authorizer {
    public static var authToken: String?
    
    public init() {
        
    }
    
    public func authorizeUser(completionHandler: @escaping AuthResponse) {
        let credsPath = Bundle.main.path(forResource: "RHCreds", ofType: "txt")
        let credsURL = URL(fileURLWithPath: credsPath!)
        do {
            if let credentials: Credentials = try? JSONDecoder().decode(Credentials.self, from: Data.init(contentsOf: credsURL)) {
                let authURL = RHApiConstants.getRHAuthUrl()
                var urlRequest = URLRequest(url: URL(string: authURL)!)
                urlRequest.httpMethod = "POST"
                let httpBody = try JSONEncoder().encode(credentials)
                let httpBodyString = String.init(data: httpBody, encoding: String.Encoding.utf8)
                urlRequest.httpBody = httpBody
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
                    (data, response, error) in
                    guard error == nil else {
                        print("Error: error calling GET")
                        completionHandler(nil, error!)
                        return
                    }
                    
                    // make sure we got data
                    guard let responseData = data else {
                        print("Error: did not receive data")
                        completionHandler(nil, error)
                        return
                    }
                    
                    do {
                        if let authToken: AuthToken = try JSONDecoder().decode(AuthToken.self, from: responseData) {
                            Authorizer.authToken = authToken.token
                            completionHandler(authToken.token, nil)
                        } else {
                            print("Nil authToken")
                            completionHandler(nil, nil)
                        }
                    } catch {
                        print("Could not decode auth token")
                        completionHandler(nil, error)
                    }
                    
                    
                })
                task.resume()
            } else {
                print("Cannot decode credentials object")
                completionHandler(nil, nil)
            }
            
        } catch {
            print(error)
            completionHandler(nil, error)
        }
        
    }
    
    internal struct Credentials: Codable {
        internal var username: String?
        internal var password: String?
    }
    
    internal struct AuthToken: Codable {
        internal var token: String?
    }
}
