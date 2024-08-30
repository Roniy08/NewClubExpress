//
//  APIClient.swift
// ClubExpress
//
//  Created by Ronit Patel on 24/04/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
//import StripeTerminal
//import Alamofire
//import PromiseKit

/*class APIClient: ConnectionTokenProvider {
    // MARK: connection token
    static let shared = APIClient()
    // API client class for communicating with backend for connection token
    // Reference: https://stripe.com/docs/terminal/payments/setup-integration?terminal-sdk-platform=ios&locale=fr-CA#connection-token
    func fetchConnectionToken(_ completion: @escaping ConnectionTokenCompletionBlock) {
        AF.request(MembershipAPIRouter.getConnectionToken(sessionToken: MembershipAPIRouter.sessionTokenStr!)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
            switch response.result {
            case .success:
                do {
                    let connectionTokenResponse = try JSONDecoder().decode(ConnectionTokenResponse.self, from: response.data!)
                    print(connectionTokenResponse.connectionSecretString)
                    if connectionTokenResponse.connectionSecretString == nil || connectionTokenResponse.connectionSecretString?.isEmpty == true
                    {
                        print("null connection token")
                    }
                    else
                    {
                            completion(connectionTokenResponse.connectionSecretString!, nil)
                    }
                                       
                } catch let err {
                    print(err.localizedDescription)
                    print(APIError.errorParseResponse)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
*/
