//
//  MembershipRemoteSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 14/12/2018.
//  
//

import Foundation
import PromiseKit
import Alamofire

protocol MembershipRemoteSource {
    func cancelRequests(command: String)
    
    func initRequest() -> Promise<InitResponse>
    func login(username: String, password: String) -> Promise<LoginResponse>
    func exchangeTokn(token: String) -> Promise<ExchangeTokenResponse>
    func createTempToken(orgId: String,memberId:String) -> Promise<CreateExchangTokenResponse>
    func getOrganisations(sessionToken: String) -> Promise<OrganisationsResponse>
    func getNavigationMenu(sessionToken: String, organisationID: String) -> Promise<NavigationMenuResponse>
    func logout(sessionToken: String) -> Promise<BaseResponse>
    func getUserInfo(sessionToken: String, organisationID: String) -> Promise<UserInfoResponse>
    func getHome(sessionToken: String, organisationID: String) -> Promise<HomeResponse>
    func getDirectory(sessionToken: String, organisationID: String, filters: Array<DirectoryRequestFilter>) -> Promise<DirectoryResponse>
    func getDirectoryFilters(sessionToken: String, organisationID: String) -> Promise<DirectoryFiltersResponse>
    func getDirectoryEntry(sessionToken: String, organisationID: String, memberID: String) -> Promise<DirectoryEntryResponse>
    func toggleDirectoryEntryFavourite(sessionToken: String, organisationID: String, memberID: String, favourited: Bool) -> Promise<BaseResponse>
    func getCalendars(sessionToken: String, organisationID: String) -> Promise<CalendarsResponse>
    func getCalendarEvents(sessionToken: String, organisationID: String, calendarIDs: Array<String>, startTimestamp: Int, endTimestamp: Int) -> Promise<CalendarEventsResponse>
    func getCalendarEventDetail(sessionToken: String, organisationID: String, entryID: String) -> Promise<CalendarEventResponse>
    func registerDeviceForPushNotifications(sessionToken: String, deviceToken: String, deviceName: String) -> Promise<BaseResponse>
    func unregisterDeviceForPushNotifications(sessionToken: String, deviceToken: String) -> Promise<BaseResponse>
    func getLocationId(sessionToken: String) -> Promise<LocationIdStripeResponse>
    func getConnectionToken(sessionToken: String) -> Promise<ConnectionTokenResponse>
}

enum APIError: Error {
    case authInvalidError
    case serializeJsonError
    case errorParseResponse
    case errorReturned(error: BaseResponse)
    case unknownError
}

class MembershipAPI: MembershipRemoteSource {
    func exchangeTokn(token: String) -> PromiseKit.Promise<ExchangeTokenResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.exchangeToken(tokenstr: token)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
//                        let connectionTokenResponse = try JSONDecoder().decode(ConnectionTokenResponse.self, from: response.data!)
                        let loginResponse = try JSONDecoder().decode(ExchangeTokenResponse.self, from: response.data!)
                        print("session tokennn:",loginResponse.sessionToken)
                        MembershipAPIRouter.homeURLStr = loginResponse.url as String
                        UserDefaults.standard.set(MembershipAPIRouter.homeURLStr!, forKey: "homeUrl")
                        seal.fulfill(loginResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    func createTempToken(orgId: String,memberId:String) -> PromiseKit.Promise<CreateExchangTokenResponse> {
        print(orgId,memberId)
        return Promise { seal in
            AF.request(MembershipAPIRouter.createTempToken(orgID: orgId, memberID: memberId)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
//                        let connectionTokenResponse = try JSONDecoder().decode(ConnectionTokenResponse.self, from: response.data!)
                        let tokenResponse = try JSONDecoder().decode(CreateExchangTokenResponse.self, from: response.data!)
//                        print("session tokennn:",loginResponse.sessionToken)
                        seal.fulfill(tokenResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func getLocationId(sessionToken: String) -> Promise<LocationIdStripeResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getStripeLocationID(sessionToken: sessionToken)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let locationResponse = try JSONDecoder().decode(LocationIdStripeResponse.self, from: response.data!)
                        seal.fulfill(locationResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    func getConnectionToken(sessionToken: String) -> Promise<ConnectionTokenResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getConnectionToken(sessionToken: sessionToken)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let connectionTokenResponse = try JSONDecoder().decode(ConnectionTokenResponse.self, from: response.data!)
                        seal.fulfill(connectionTokenResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func initRequest() -> Promise<InitResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.initRequest).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let initResponse = try JSONDecoder().decode(InitResponse.self, from: response.data!)
                        seal.fulfill(initResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func login(username: String, password: String) -> Promise<LoginResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.login(username: username, password: password)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: response.data!)
                        seal.fulfill(loginResponse)

                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
            }
        }
    }
    
    func getOrganisations(sessionToken: String) -> Promise<OrganisationsResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getOrganisations(sessionToken: sessionToken)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    if let organisationsResponse = try? JSONDecoder().decode(OrganisationsResponse.self, from: response.data!) {
                        seal.fulfill(organisationsResponse)
//                        MembershipAPIRouter.tempSessionTokenStr = sessionToken
                    } else if let errorResponse = try? JSONDecoder().decode(BaseResponse.self, from: response.data!) {
                        seal.reject(APIError.errorReturned(error: errorResponse))
                    } else {
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                print(error)
                    seal.reject(error)
                }
            }
        }
    }
    
    func getNavigationMenu(sessionToken: String, organisationID: String) -> Promise<NavigationMenuResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getNavigationMenu(sessionToken: sessionToken, organisationID: organisationID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let navigationMenuResponse = try JSONDecoder().decode(NavigationMenuResponse.self, from: response.data!)
                        seal.fulfill(navigationMenuResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func logout(sessionToken: String) -> Promise<BaseResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.logout(sessionToken: sessionToken)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let logoutResponse = try JSONDecoder().decode(BaseResponse.self, from: response.data!)
                        seal.fulfill(logoutResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getUserInfo(sessionToken: String, organisationID: String) -> Promise<UserInfoResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getUserInfo(sessionToken: sessionToken, organisationID: organisationID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let userInfoResponse = try JSONDecoder().decode(UserInfoResponse.self, from: response.data!)
                        seal.fulfill(userInfoResponse)
//                        if let jsonObject = try? JSONSerialization.jsonObject(with: response.data!, options: []),
//                           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
//                           let jsonString = String(data: jsonData, encoding: .utf8) {
//                            print(jsonString)
//                        } else {
//                            print("Data could not be pretty printed")
//                        }
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getHome(sessionToken: String, organisationID: String) -> Promise<HomeResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.home(sessionToken: sessionToken, organisationID: organisationID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let homeResponse = try JSONDecoder().decode(HomeResponse.self, from: response.data!)
                        seal.fulfill(homeResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getDirectory(sessionToken: String, organisationID: String, filters: Array<DirectoryRequestFilter>) -> Promise<DirectoryResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getDirectory(sessionToken: sessionToken, organisationID: organisationID, filters: filters)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    if let directoryResponse = try? JSONDecoder().decode(DirectoryResponse.self, from: response.data!) {
                        seal.fulfill(directoryResponse)
                    } else if let errorResponse = try? JSONDecoder().decode(BaseResponse.self, from: response.data!) {
                        seal.reject(APIError.errorReturned(error: errorResponse))
                    } else {
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getDirectoryFilters(sessionToken: String, organisationID: String) -> Promise<DirectoryFiltersResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getDirectoryFilters(sessionToken: sessionToken, organisationID: organisationID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let directoryFiltersResponse = try JSONDecoder().decode(DirectoryFiltersResponse.self, from: response.data!)
                        seal.fulfill(directoryFiltersResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getDirectoryEntry(sessionToken: String, organisationID: String, memberID: String) -> Promise<DirectoryEntryResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getDirectoryEntry(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let directoryEntryResponse = try JSONDecoder().decode(DirectoryEntryResponse.self, from: response.data!)
                        seal.fulfill(directoryEntryResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func toggleDirectoryEntryFavourite(sessionToken: String, organisationID: String, memberID: String, favourited: Bool) -> Promise<BaseResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.toggleDirectoryEntryFavourite(sessionToken: sessionToken, organisationID: organisationID, memberID: memberID, favourited: favourited)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let response = try JSONDecoder().decode(BaseResponse.self, from: response.data!)
                        seal.fulfill(response)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getCalendars(sessionToken: String, organisationID: String) -> Promise<CalendarsResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getCalendars(sessionToken: sessionToken, organisationID: organisationID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let calendarsResonse = try JSONDecoder().decode(CalendarsResponse.self, from: response.data!)
                        seal.fulfill(calendarsResonse)
                    } catch let err {
                        print(err.localizedDescription)
                        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
                    seal.reject(error)
                }
            }
        }
    }
    
    
   // if let baseResponse = try? JSONDecoder().decode(BaseResponse.self, from: data) {
   //                    if let errorCode = baseResponse.errorCode {
   //                        if errorCode == "AUTH" {
   //                            //Send notification to logout
   //                            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
   //
   //                            return .failure(APIError.authInvalidError)
   //                        }
   //                    }
   //                }
        
    func getCalendarEvents(sessionToken: String, organisationID: String, calendarIDs: Array<String>, startTimestamp: Int, endTimestamp: Int) -> Promise<CalendarEventsResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getCalendarEvents(sessionToken: sessionToken, organisationID: organisationID, calendarIDs: calendarIDs, startTimestamp: startTimestamp, endTimestamp: endTimestamp)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let calendarEventsResonse = try JSONDecoder().decode(CalendarEventsResponse.self, from: response.data!)
                        seal.fulfill(calendarEventsResonse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getCalendarEventDetail(sessionToken: String, organisationID: String, entryID: String) -> Promise<CalendarEventResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.getCalendarEventDetail(sessionToken: sessionToken, organisationID: organisationID, entryID: entryID)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let calendarEventDetailResonse = try JSONDecoder().decode(CalendarEventResponse.self, from: response.data!)
                        seal.fulfill(calendarEventDetailResonse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func registerDeviceForPushNotifications(sessionToken: String, deviceToken: String, deviceName: String) -> Promise<BaseResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.registerDeviceForPushNotifications(sessionToken: sessionToken, deviceToken: deviceToken, deviceName: deviceName)).validate(statusCode: 200..<300).responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let registerResponse = try JSONDecoder().decode(BaseResponse.self, from: response.data!)
                        seal.fulfill(registerResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }

        }
    }
    
    func unregisterDeviceForPushNotifications(sessionToken: String, deviceToken: String) -> Promise<BaseResponse> {
        return Promise { seal in
            AF.request(MembershipAPIRouter.unregisterDeviceForPushNotifications(sessionToken: sessionToken, deviceToken: deviceToken)).validate(statusCode: 200..<300) .responseDecodable(of: BaseResponse.self) { response in
                switch response.result {
                case .success:
                    do {
                        let unregisterResponse = try JSONDecoder().decode(BaseResponse.self, from: response.data!)
                        seal.fulfill(unregisterResponse)
                    } catch let err {
                        print(err.localizedDescription)
                        seal.reject(APIError.errorParseResponse)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}

extension MembershipAPI {
    func cancelRequests(command: String) {
        AF.session.getAllTasks { (tasks) in
            //Find tasks matching command in url parameter
            let matchingTasks = tasks.filter({ (task) -> Bool in
                if let bodyData = task.originalRequest?.httpBody {
                    if let bodyString = String(data: bodyData, encoding: .utf8) {
                        //get body parameters
                        var paramaters = Dictionary<String,String>()
                        let paramPairs = bodyString.components(separatedBy: "&")
                        for paramPair in paramPairs {
                            let keyValue = paramPair.components(separatedBy: "=")
                            if keyValue.count == 2 {
                                paramaters.updateValue(keyValue[1], forKey: keyValue[0])
                            }
                        }
                        
                        //check for command parameter
                        if let commandValue = paramaters["command"] {
                            if commandValue == command {
                                return true
                            }
                        }
                    }
                }
                return false
            })
            matchingTasks.forEach({ (task) in
                task.cancel()
            })
        }
    }
}



    
extension DataRequest {
//    static func JSONSerializerAndCheckAuth(
//        options: JSONSerialization.ReadingOptions = .allowFragments)
//        -> DataResponseSerializer
//    {
//        return DataResponseSerializer { response, data, error in
//            //Check AUTH error
//            if let data = data {
//                if let baseResponse = try? JSONDecoder().decode(BaseResponse.self, from: data) {
//                    if let errorCode = baseResponse.errorCode {
//                        if errorCode == "AUTH" {
//                            //Send notification to logout
//                            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "AuthInvalidNotification"), object: nil)
//
//                            return .failure(APIError.authInvalidError)
//                        }
//                    }
//                }
//            }
//
//            //Parse JSON
//            let result = Request.serializeResponseJSON(options: options, response: response, data: data, error: error)
//            return result
//        }
//    }
//
//    @discardableResult
//    public func responseJSONValidAuth(
//        queue: DispatchQueue? = nil,
//        options: JSONSerialization.ReadingOptions = .allowFragments,
//        completionHandler: @escaping (DataResponse<Data, AFError>) -> Void)
//        -> Self
//    {
//        return response(
//            queue: queue!,
//            responseSerializer: DataRequest.JSONSerializerAndCheckAuth(options: options),
//            completionHandler: completionHandler
//        )
//    }
}
