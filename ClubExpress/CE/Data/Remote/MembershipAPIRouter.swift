//
// CEAPIRouter.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation
import Alamofire

enum MembershipAPIRouter: URLRequestConvertible {
    case initRequest
    case login(username: String, password: String)
    case exchangeToken(tokenstr: String)
    case createTempToken(orgID: String,memberID:String)
    case getOrganisations(sessionToken: String)
    case getNavigationMenu(sessionToken: String, organisationID: String)
    case logout(sessionToken: String)
    case getUserInfo(sessionToken: String, organisationID: String)
    case home(sessionToken: String, organisationID: String)
    case getDirectory(sessionToken: String, organisationID: String, filters: Array<DirectoryRequestFilter>)
    case getDirectoryFilters(sessionToken: String, organisationID: String)
    case getDirectoryEntry(sessionToken: String, organisationID: String, memberID: String)
    case toggleDirectoryEntryFavourite(sessionToken: String, organisationID: String, memberID: String, favourited: Bool)
    case getCalendars(sessionToken: String, organisationID: String)
    case getCalendarEvents(sessionToken: String, organisationID: String, calendarIDs: Array<String>, startTimestamp: Int, endTimestamp: Int)
    case getCalendarEventDetail(sessionToken: String, organisationID: String, entryID: String)
    case registerDeviceForPushNotifications(sessionToken: String, deviceToken: String, deviceName: String)
    case unregisterDeviceForPushNotifications(sessionToken: String, deviceToken: String)
    case getStripeLocationID(sessionToken: String)
    case getConnectionToken(sessionToken: String)
    
    fileprivate static var apiUrl = "https://wstest.clubexpress.com/app_handler.ashx" // default production is enabled
    
    static var serverUrlInfo: String?
    static var serverCustomIP: String?
    static var userInfoRes: UserInfo?
    static var userServerOptionsList : String?
    static var serverRouteURL: String?
    static var storeURL: String?
    static var storeorgCount: Int?
    static var stripe_publishable_key: String?
    static var stripe_Location_Id: String?
    static var stripe_ConnectedAccount_Id: String?
    static var stripe_Client_Secret: String?
    static var isUserBiometricSaved = false
    static var tempSessionTokenStr: String?
    static var tempMemberIDStr: String?
    static var tempOrgIDStr: String?
    static var homeURLStr: String?
    
    // change the server according to
    static func processServerUrl() {

        if apiUrl.isEmpty || apiUrl == "" || serverUrlInfo == ""
        {
            apiUrl = "https://wstest.clubexpress.com/app_handler.ashx" // production
            userServerOptionsList = "https://wstest.clubexpress.com/app_handler.ashx"
            print("current server is production")
        }
        else if serverUrlInfo == "Other"
        {
            print("custom address") // ip address
            apiUrl = serverCustomIP!
        }
        else if serverUrlInfo != ""
        {
            apiUrl = userServerOptionsList!
        }
        
        print("current api endpoint: ",apiUrl)
      }
    
    fileprivate var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }
    
    fileprivate var path: String {
        switch self {
        default:
            return ""
        }
    }
    
    fileprivate var bodyParameters: Parameters {
        switch self {
        case .initRequest:
            return [
                "command": "init"
            ]
        case .login(let username, let password):
            return [
                "command": "login",
                "email": username,
                "password": password,
//                "build_version": appVersion
            ]
        case .exchangeToken(let tokenstr):
            return [
                "command": "exchange",
                "token": tokenstr,
            ]
        case .createTempToken(let orgID,let memberID):
            return [
                "command": "token",
                "org_id": orgID,
                "member_id": memberID
            ]
        case .getOrganisations(let sessionToken):
            return [
                "command": "list-orgs",
                "session_token": sessionToken
            ]
        case .getNavigationMenu(let sessionToken, let organisationID):
            return [
                "command": "navigation",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
        case .logout(let sessionToken):
            return [
                "command": "logout",
                "session_token": sessionToken
            ]
        case .home(let sessionToken, let organisationID):
            return [
                "command": "home",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
            // here for base url change
        case .getUserInfo(let sessionToken, let organisationID):
            return [
                "command": "user-info",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
        case .getDirectory(let sessionToken, let organisationID, let filters):
            var directoryBody = [
                "command": "directory",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
            if filters.count > 0 {
                if let filtersJson = createJsonFromFilters(filters: filters) {
                    directoryBody["filters"] = filtersJson
                }
            }
            return directoryBody
        case .getDirectoryFilters(let sessionToken, let organisationID):
            return [
                "command": "directory-filters",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
        case .getDirectoryEntry(let sessionToken, let organisationID, let memberID):
            return [
                "command": "directory-entry",
                "session_token": sessionToken,
                "org_id": organisationID,
                "member_id": memberID
            ]
        case .toggleDirectoryEntryFavourite(let sessionToken, let organisationID, let memberID, let favourited):
            return [
                "command": "directory-entry-favorite",
                "session_token": sessionToken,
                "org_id": organisationID,
                "member_id": memberID,
                "is_favorite": favourited ? "true" : "false"
            ]
        case .getCalendars(let sessionToken, let organisationID):
            return [
                "command": "list-calendars",
                "session_token": sessionToken,
                "org_id": organisationID
            ]
        case .getCalendarEvents(let sessionToken, let organisationID, let calendarIDs, let startTimestamp, let endTimestamp):
            return [
                "command": "calendar-entries",
                "session_token": sessionToken,
                "org_id": organisationID,
                "calendar_id": createStringFromArray(array: calendarIDs),
                "start_timestamp": startTimestamp,
                "end_timestamp": endTimestamp
            ]
        case .getCalendarEventDetail(let sessionToken, let organisationID, let entryID):
            return [
                "command": "calendar-entry",
                "session_token": sessionToken,
                "org_id": organisationID,
                "entry_id": entryID
            ]
        case .registerDeviceForPushNotifications(let sessionToken, let deviceToken, let deviceName):
            return [
                "command": "register-device",
                "session_token": sessionToken,
                "device_platform": "ios",
                "device_token": deviceToken,
                "device_name": deviceName
            ]
        case .unregisterDeviceForPushNotifications(let sessionToken, let deviceToken):
            return [
                "command": "unregister-device",
                "session_token": sessionToken,
                "device_token": deviceToken
            ]
        case .getStripeLocationID(sessionToken: let sessionToken):
            return [
                "command": "get-stripe-location-id",
                "session_token": sessionToken
            ]
        case .getConnectionToken(sessionToken: let sessionToken):
            return [
                "command": "get-stripe-connection-token",
                "session_token": sessionToken
            ]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try MembershipAPIRouter.apiUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        print(urlRequest)
        urlRequest.httpMethod = method.rawValue
        //print("url request",urlRequest)
        urlRequest = try URLEncoding.httpBody.encode(urlRequest, with: bodyParameters)
      //  print("body parameter",bodyParameters)
        print(String(data: urlRequest.httpBody!, encoding: String.Encoding.utf8)!)
        return urlRequest
    }
}

extension MembershipAPIRouter {
    fileprivate func createJsonFromFilters(filters: Array<DirectoryRequestFilter>) -> String? {
        if let jsonData = try? JSONEncoder().encode(filters) {
            return String(data: jsonData, encoding: .utf8)!
        }
        return nil
    }
    
    fileprivate func createStringFromArray(array: Array<String>) -> String {
        let joinedArray = array.joined(separator: ",")
        return "[\(joinedArray)]"
    }
}
