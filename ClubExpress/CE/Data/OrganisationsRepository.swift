//
//  OrganisationsRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class OrganisationsRepository {
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    
    init(membershipRemoteSource: MembershipRemoteSource) {
        self.membershipRemoteSource = membershipRemoteSource
    }
    
    func getOrganisations(sessionToken: String) -> Promise<OrganisationsResponse> {
        return Promise { seal in
            membershipRemoteSource.getOrganisations(sessionToken: sessionToken).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getUserInfo(sessionToken: String, organisationID: String) -> Promise<UserInfoResponse> {
        return Promise { seal in
            membershipRemoteSource.getUserInfo(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    func exchangeTokn(tokenstr: String) -> Promise<ExchangeTokenResponse> {
        return Promise { seal in
            membershipRemoteSource.exchangeTokn(token: tokenstr).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
        
    }
    
    func getExchangeToken(org_id: String, member_id: String) -> Promise<CreateExchangTokenResponse>
    {
        return Promise{ seal in membershipRemoteSource.createTempToken(orgId: org_id, memberId: member_id).done { response in
            seal.fulfill(response)
        }.catch { error in
            print(error)
            seal.reject(error)
        }
      }
    }
        func getNavigationMenu(sessionToken: String, organisationID: String) -> Promise<NavigationMenuResponse> {
            return Promise { seal in
                membershipRemoteSource.getNavigationMenu(sessionToken: sessionToken, organisationID: organisationID).done { response in
                    seal.fulfill(response)
                }.catch{ error in
                    seal.reject(error)
                }
            }
        }
        
        func getHomeContent(sessionToken: String, organisationID: String) -> Promise<HomeResponse> {
            return Promise { seal in
                membershipRemoteSource.getHome(sessionToken: sessionToken, organisationID: MembershipAPIRouter.tempOrgIDStr!).done { response in
                    seal.fulfill(response)
                }.catch{ error in
                    seal.reject(error)
                }
            }
        }
        
        func refreshUnreadCount(sessionToken: String, organisationID: String) -> Promise<Int> {
            return Promise { seal in
                membershipRemoteSource.getUserInfo(sessionToken: sessionToken, organisationID: organisationID).done { response in
                    var totalCount = 0
                    for org in response.orgUnreadCounts ?? [:] {
                        totalCount += Int(org.value) ?? 0
                    }
                    seal.fulfill(Int(totalCount) ?? 0)
                    //                if let unreadCount = response.unreadOrgNotifications {
                    //                    seal.fulfill(Int(unreadCount) ?? 0)
                    //                }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        func refreshUnreadCurrentCount(sessionToken: String, organisationID: String) -> Promise<Int> {
            return Promise { seal in
                membershipRemoteSource.getUserInfo(sessionToken: sessionToken, organisationID: organisationID).done { response in
                    var currentOrgUnreadCount = response.unreadOrgNotifications ?? "0"
                    
                    seal.fulfill(Int(currentOrgUnreadCount) ?? 0)
                    //                }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
