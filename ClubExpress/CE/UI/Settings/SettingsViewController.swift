//
//  SettingsViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/02/2019.
//  
//

import UIKit

//settings table
class SettingsViewController: UIViewController,PresenterDelegate {
   
    var nextActionButton = UIButton(type: .system)
    var userInfoRes: UserInfo?
    var organisationColours: OrganisationColours!
    var server_optionsList  = [[String: String]]()
    var presenter: SettingsPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    var sections = Array<SettingsSection>()
    weak var delegate: SettingsDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter!.delegate = self
        presenter?.viewDidLoad()
        presenter!.getUserEndPoints()
    }
    func refreshServerOptions()
    {
        delegate?.gotoLogout()
    }
    func onDataReceived(data: [[String : String]]) {
        if data.count > 0 || data != nil
        {
            server_optionsList = data
        }
    }

    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        footerLabel.font = UIFont.openSansFontOfSize(size: 13)
        footerLabel.textColor = UIColor(red: 143/255, green: 144/255, blue: 146/255, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeTableViewFooterHeight()
    }
    
    fileprivate func resizeTableViewFooterHeight() {
        if let tableViewFooter = tableView.tableFooterView {
            tableViewFooter.layoutIfNeeded()
            let size = tableViewFooter.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let newHeight = size.height
            tableViewFooter.frame.size.height = newHeight
            tableView.tableFooterView = tableViewFooter
            tableView.layoutIfNeeded()
        }
    }
    
    @objc func appDidBecomeActive(notification: Notification) {
        presenter?.appDidBecomeActive()
    }
}

extension SettingsViewController: SettingsView {
    
    func setSections(sections: Array<SettingsSection>) {
        self.sections = sections
        tableView.reloadData()
    }
    
    func presentWebView(webContentEntry: WebContentItem) {
        if let webContentVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController {
            webContentVC.webContentEntry = webContentEntry
            webContentVC.delegate = self
            navigationController?.pushViewController(webContentVC, animated: true)
        }
    }
    func showServerSwitchActionSheet() {
        let serverActionSheet = UIAlertController(title: "select server option", message: nil, preferredStyle: .actionSheet)
        
        for endpoint in server_optionsList {
            if let label = endpoint["label"] as? String,
               let url = endpoint["url"] as? String {
                let action = UIAlertAction(title: label, style: .default) { _ in
                    // Perform action with selected endpoint URL
                        //print("Selected endpoint URL: \(url)")
                        self.delegate?.forceLogoutForServer()
                        let serverUrlType = label
                        MembershipAPIRouter.serverUrlInfo = serverUrlType
                        MembershipAPIRouter.userServerOptionsList = url
                        MembershipAPIRouter.processServerUrl()
                }
                serverActionSheet.addAction(action)
            }
        }
        let callOtherAction = UIAlertAction(title: "Other", style: .default) { (action) in
            // here action on production
            self.showInputDialog(title: "Add IP Address",
                            subtitle: "",
                            actionTitle: "Add",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "IP Address",
                                 inputKeyboardType: .URL, actionHandler:
                                    { (input:String?) in
                                        print("The new IP address is \(input ?? "")")
                                        if ((input?.isEmpty) == nil)
                                        {
                                            self.showAlertPopup(title: "Error", message: "Enter IP Address and try again.")
                                        }
                                        else
                                        {
                                            self.delegate?.forceLogoutForServer()
                                            let serverUrlType = "Other"
                                            MembershipAPIRouter.serverUrlInfo = serverUrlType
                                            MembershipAPIRouter.serverCustomIP = input!
                                            MembershipAPIRouter.processServerUrl()
                                        }
                                    })
//            self.delegate?.forceLogoutForServer()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        serverActionSheet.addAction(callOtherAction)
        serverActionSheet.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = serverActionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            }
            present(serverActionSheet, animated: true, completion: nil)
        }
        else
        {
            present(serverActionSheet, animated: true, completion: nil)

        }
   

    }
    
    func showLogoutPopup() {
        let logoutAlertVC = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let serverUrlType = ""
            MembershipAPIRouter.serverUrlInfo = serverUrlType
            MembershipAPIRouter.userServerOptionsList = ""
            MembershipAPIRouter.processServerUrl()
            self.presenter?.logoutConfirmed()
        }
        logoutAlertVC.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        logoutAlertVC.addAction(noAction)
        logoutAlertVC.preferredAction = noAction
        present(logoutAlertVC, animated: true, completion: nil)
    }
    func showGotoSettingsAlert(message: String) {
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func showGotoSettings(message: String) {
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func gotoLogout() {
        delegate?.gotoLogout()
    }
    func forceLogoutForServer()
    {
        delegate?.forceLogoutForServer()
    }
    
    func sendSwapOrgEvent() {
        delegate?.swapOrgPressed()
    }
    
    func setFooterString(string: String) {
        footerLabel.text = string
        resizeTableViewFooterHeight()
    }
    
    func showNotificationsToggleError() {
        showAlertPopup(title: "Notifications Error", message: "Notifications could not be toggled. Please try again.")
    }
    func showAlertMessage(title: String,message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Handle OK button tapped
        }

        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showNotificationsPermissionPopup() {
        NotificationsPermissionUtil.showNotificationsPermissionPopup(callback: { (success) in
            DispatchQueue.main.async {
                self.presenter?.respondedToNotificationsPermissionPopup(success: success)
            }
        })
    }
    
    func showNotificationsDeniedPopup() {
        showAlertPopup(title: "Notifications Error", message: "Notifications are disabled. Enable Notifications under the Membership Toolkit section in the Settings app and try again.")
    }
    
    func addAppDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        let items = section.items
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let items = section.items
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell", for: indexPath) as! SettingsItemCell
        cell.organisationColours = self.organisationColours
        cell.configure(item: item)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = sections[indexPath.section]
        let items = section.items
        let item = items[indexPath.row]
        
        if let type = item.accessoryType {
            if type == .toggleSwitch {
                return false
            }
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let items = section.items
        let item = items[indexPath.row]
        presenter?.itemPressed(item: item)
    }
}

extension SettingsViewController: SettingsItemCellDelegate {
    func toggleSwitched(item: SettingsItem, enabled: Bool) {
        presenter?.toggleSwitched(item: item, enabled: enabled)
    }
}

extension SettingsViewController: WebContentDelegate {
    func openLinkToNativePage(url: String) {
        delegate?.openLinkToNativePage(url: url)
    }
    
    func gotoCart() {
        delegate?.gotoCart()
    }
}
extension SettingsViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
