//
//  OrganisationsViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import SwinjectStoryboard
import UserNotifications


class OrganisationsViewController: UIViewController {
    
//    var organisationColours: OrganisationColours!
    var presenter: OrganisationsPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    var isAdmin: Bool? = nil
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
//    fileprivate var organisations = Array<Organisation>()
    fileprivate var orgsLists = Array<OrgLogin>()
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var loadingOrganisationView: OverlayView?
    fileprivate var emptyPlaceholderView: EmptyPlaceholder?
    var switchingOrganisation = false {
        didSet {
            presenter?.switchingOrganisation = switchingOrganisation
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isInitialLoad: Bool = true
    var isTextType: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineLogoutButtonText()
        setupView()
        getLogoutButtonText()
//        addPullToRefresh()
//        presenter?.interactor.getUserInfo(organisationID: "")
        presenter?.viewDidLoad()
        searchBar.showsBookmarkButton = true
        setKeyboardInputButtonText(text: "123")
        if let savedOrgs = self.retrieveOrgsFromUserDefaults() {
            print(savedOrgs[0].org_name)
            orgsLists = savedOrgs
        } else {
            print("No orgs found in UserDefaults")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        view.layoutIfNeeded()

        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
            
            tableViewBottomConstraint.constant = -keyboardSize.height
            
            let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func retrieveOrgsFromUserDefaults() -> [OrgLogin]? {
        if let data = UserDefaults.standard.data(forKey: "orgsList") {
            do {
                let orgs = try JSONDecoder().decode([OrgLogin].self, from: data)
                return orgs
            } catch {
                print("Failed to decode orgs: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    @objc func keyboardWillHide(notification: Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        
        tableViewBottomConstraint.constant = .zero
        
        let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func determineLogoutButtonText(){
        if(switchingOrganisation == false){
            isInitialLoad = true
        }
        else{
            isInitialLoad = false
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
       print("click")
        isTextType = !isTextType
        if(!isTextType){
            setKeyboardInputButtonText(text: "ABC")
            searchBar.inputAccessoryView = getDoneButton()
            searchBar.keyboardType = UIKeyboardType.numberPad
            searchBar.setNeedsLayout()
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        else{
            setKeyboardInputButtonText(text: "123")
            searchBar.inputAccessoryView = nil
            searchBar.keyboardType = UIKeyboardType.alphabet
            searchBar.setNeedsLayout()
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
       
    }
    
    func getDoneButton()->UIToolbar{
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSearchBar))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        return doneToolbar
    }
    
    @objc func dismissSearchBar() {
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
             // your Action According to your textfield
            return true
        }
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func setKeyboardInputButtonText(text: String){
        let rect = CGRect(x:0, y:0, width:40, height:30)
        let dynamicView=UIView(frame: rect)
        dynamicView.backgroundColor = UIColorFromRGB(rgbValue: 0xeeeff0)
        dynamicView.roundCorners(corners: .allCorners, radius: 4, rect: rect)
        let label = UILabel(frame: CGRect(x:5, y:5, width:30, height:20))
        label.font = label.font.withSize(12)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColorFromRGB(rgbValue: 0x8e8e93)
        dynamicView.addSubview(label)
        searchBar.setImage(dynamicView.asImage(), for: .bookmark, state: .normal)
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        footerLabel.textColor = UIColor(red: 143/255, green: 144/255, blue: 146/255, alpha: 1.0)
        footerLabel.font = UIFont.openSansFontOfSize(size: 14)

        searchView.backgroundColor = UIColor.mtBrandBlueDark
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = UIColor.white
        }

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mtMatteBlack]
        searchBar.tintColor = UIColor.mtBrandBlueDark

        searchBar.barTintColor = UIColor.mtBrandBlueDark
        searchBar.isTranslucent = false
        
        self.searchBar.delegate = self

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func addPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setFooterSize()
    }
    
    @objc func pulledToRefresh(control: UIRefreshControl) {
        presenter?.pulledToRefresh()
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        if(isInitialLoad){
            let serverUrlType = ""
            MembershipAPIRouter.serverUrlInfo = serverUrlType
            MembershipAPIRouter.processServerUrl()
            presenter?.logoutBtnPressed()
        }
        else{
            let orgId = UserDefaults.standard.string(forKey: "orgId") ?? ""
            if orgId != ""
            {
                let intOrgId = Int(orgId)
                let organisation = orgsLists.first(where: { $0.org_id == intOrgId })
                 if(organisation != nil) {
//                     presenter?.didSelectOrganisation(organisation: organisation!)
                 }
            }
            else
            {
                
            }
        }
        
    }
    
    
    fileprivate func setFooterSize() {
        //set TableView footer size
        if let footerView = tableView.tableFooterView {
            let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if footerView.frame.height != size.height {
                footerView.frame.size.height = size.height
                tableView.tableFooterView = footerView
            }
        }
    }
    
}

extension OrganisationsViewController: OrganisationsView {
//    func setOrganisationsArray(organisations: Array<Organisation>) {
//        <#code#>
//    }
    
    func setOrganisationsArray(organisations: Array<OrgLogin>) {
        self.orgsLists = organisations
        if(self.searchBar.text!.count > 0 || self.searchBar.isFocused){
            self.searchBarHeightConstraint.constant = 53
        }
        else{
            if(organisations.count >= 10){
                self.searchBarHeightConstraint.constant = 53
            }
            else{
                self.searchBarHeightConstraint.constant = 0
            }
        }
       
        self.searchView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    func getLogoutButtonText() {
        if(isInitialLoad){
            logoutBtn.title = "Back"
        }
        else{
            logoutBtn.title = "Cancel"
        }
    }
    func showErrorLoadingOrganisationsPopup(message: String) {
        let alertVC = UIAlertController(title: "Error Loading Organizations", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(closeAction)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
                self.presenter?.logoutActionPressed()
          
           
        }
        alertVC.addAction(logoutAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showErrorLoadingSelectedOrganisationPopup(message: String) {
        showAlertPopup(title: "Error Loading Organization", message: message)
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        switch loading {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
    }
    
    func toggleFooterView(show: Bool) {
        switch show {
        case true:
            tableView.tableFooterView?.isHidden = false
        case false:
            tableView.tableFooterView?.isHidden = true
        }
    }
    
    func navigateToSelectedOrganisation() {
        guard let organisationWrapperVC = storyboard?.instantiateViewController(withIdentifier: "organisationWrapperVC") as? OrganisationWrapperViewController else { return }
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        
       organisationWrapperVC.view.layoutIfNeeded()

        UIView.transition(with: appDelegate.window!!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
            appDelegate.window??.rootViewController = organisationWrapperVC
            appDelegate.window??.makeKeyAndVisible()
        }, completion: nil)
    }
    
    func endRefreshControlAnimating() {
        refreshControl.endRefreshing()
    }
    
    func showOrganisationLoadingView(afterDelay: Bool) {
        if loadingOrganisationView == nil {
            loadingOrganisationView = OverlayView()
            loadingOrganisationView?.message = "Loading selected organization..."
            loadingOrganisationView!.frame = view.frame
            loadingOrganisationView?.translatesAutoresizingMaskIntoConstraints = false
            
            if afterDelay {
                loadingOrganisationView!.alpha = 0
            }
            
            view.addSubview(loadingOrganisationView!)
            
            loadingOrganisationView!.constraintToSuperView(superView: view)
            
            if afterDelay {
                UIView.animate(withDuration: 0, delay: 1, animations: {
                    self.loadingOrganisationView!.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    func removeOrganisationLoadingView() {
        loadingOrganisationView?.removeFromSuperview()
        loadingOrganisationView = nil
    }
    
    func showEmptyPlaceholderView(title: String, message: String) {
        removeEmptyPlaceholderView()
        
        if emptyPlaceholderView == nil {
            emptyPlaceholderView = EmptyPlaceholder()
            emptyPlaceholderView!.frame = tableView.bounds
            
            emptyPlaceholderView!.title = title
            emptyPlaceholderView!.message = message
            
            tableView.backgroundView = emptyPlaceholderView!
            
            emptyPlaceholderView!.updateText()
        }
    }
    
    func removeEmptyPlaceholderView() {
        emptyPlaceholderView?.removeFromSuperview()
        emptyPlaceholderView = nil
        tableView.backgroundView = nil
    }
    
    func setFooterText(footerText: String) {
        footerLabel.text = footerText
        setFooterSize()
    }
    
    func showPreNotificationsPermissionPopup() {
        let notificationsAlertVC = UIAlertController(title: "Enable Notifications?", message: "Do you want to enable push notifications to receive updates from your organizations?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            NotificationsPermissionUtil.showNotificationsPermissionPopup(callback: { (success) in
                self.presenter?.respondedToNotificationsPermissionPopup(success: success)
            })
        }
        notificationsAlertVC.addAction(yesAction)
        let noAction = UIAlertAction(title: "Not now", style: .cancel) { (action) in
            
        }
        notificationsAlertVC.addAction(noAction)
        notificationsAlertVC.preferredAction = yesAction
        present(notificationsAlertVC, animated: true, completion: nil)
    }
    
    func changeToLoginVC() {
        guard let loginNC = storyboard?.instantiateViewController(withIdentifier: "loginNC") as? LoginNavigationController else { return }
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
        
        loginNC.setViewControllers([loginVC], animated: false)
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        
        loginNC.view.layoutIfNeeded()
        
        UIView.transition(with: appDelegate.window!!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            appDelegate.window??.rootViewController = loginNC
            appDelegate.window??.makeKeyAndVisible()
        }, completion: nil)
    }
    
    func changePageToWebContent(url: String) {
        if let webContentVC = storyboard?.instantiateViewController(withIdentifier: "webContentVC") as? WebContentViewController {
            webContentVC.webContentEntry = WebContentItem(title: "", url: url, content: nil)
            webContentVC.isUrlWhileLoggedOut = false
            webContentVC.showCartBtn = false
            webContentVC.delegate = self
            navigationController?.pushViewController(webContentVC, animated: true)
        }
    }
    
    func closeWebView() {
        if navigationController?.visibleViewController is WebContentViewController {
            navigationController?.popViewController(animated: true)
        }
    }
  
}


extension OrganisationsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
//        presenter?.searchBtnPressed(searchTerm: searchTerm, isAdmin: isAdmin)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchTerm = searchBar.text else { return }
//        presenter?.searchTermDidChange(searchTerm: searchTerm)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        presenter?.cancelSearchBtnPressed()
    }
}

extension OrganisationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orgsLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganisationCell", for: indexPath) as! OrganisationCell
        let organisation = orgsLists[indexPath.row]
        cell.configure(organisation: organisation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let organisation = orgsLists[indexPath.row]
//        UserDefaults.standard.set("\(orgsLists[indexPath.row].org_id)", forKey: "orgId")
        presenter?.didSelectOrganisation(organisation: organisation)
    }
}

extension OrganisationsViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension OrganisationsViewController: WebContentDelegate {
    func openLinkToNativePage(url: String) {
        presenter?.webViewOpenedLinkToNativePage(url: url)
    }
    func gotoCart() { }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func searchOrgByName(orgs: [OrgLogin], name: String) -> (orgId: Int, memberId: Int)? {
        for org in orgs {
            if org.org_name == name {
                print(org.org_id,org.member_id)
                return (orgId: org.org_id, memberId: org.member_id) as! (orgId: Int, memberId: Int)
            }
        }
        return nil
    }
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

@available(iOS 13.0, *)
class UITextFieldWithDoneButton: UISearchTextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addDoneButtonOnKeyboard()
    }

    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc fileprivate func doneButtonAction() {
        self.resignFirstResponder()
    }
}
