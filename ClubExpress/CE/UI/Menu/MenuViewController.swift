//
//  MenuViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class MenuViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var presenter: MenuPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    var menuState:MenuState?
    var selectedMenuEntry: NavigationEntry?
    fileprivate var menuEntries: Array<NavigationEntry> = []
    var openEntries = Set<NavigationEntry>()
    weak var menuActionDelegate: MenuActionDelegate?
    var selectMenuItemFromUrl: String?
    var basketIconView: BasketIconView?
    var Menupresenter: MenuPresenter?
    var unreadNotificationsOrgCount = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orgLogoImageView: UIImageView!
    @IBOutlet weak var swapOrgBtnWrapper: UIView!
    @IBOutlet weak var swapOrgBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var orgLogoImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var basketWrapper: UIView!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var orgNameBtn: UIButton!
    
    @IBOutlet weak var lblServerStatus: UILabel!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var notificationCountView: UIView!
    fileprivate var InteractorLocationId: LocationIdInteractor?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setOtherAppNotificationCount(notification:)), name: NSNotification.Name(rawValue: "setOtherAppNotificationCount"), object: nil)
        setOtherAppNotificationCountFromStorage()
        setupView()
        
        if let selectedMenuEntry = self.selectedMenuEntry {
            presenter?.selectedMenuEntry = selectedMenuEntry
        }
        
        presenter?.menuLoaded()
        lblServerStatus.textColor = UIColor.red
        if let selectMenuItemFromUrl = self.selectMenuItemFromUrl {
            presenter?.selectMenuItemFromUrl(url: selectMenuItemFromUrl)
            self.selectMenuItemFromUrl = nil
        }
        if let myString = MembershipAPIRouter.serverUrlInfo {

            if(myString.contains("Production") || myString == "")
            {
                lblServerStatus.isHidden = true
            }
            else
            {
                lblServerStatus.isHidden = false
                lblServerStatus.text = myString
            }

        }
        else
        {
            lblServerStatus.isHidden = true
        }
    }
    fileprivate func setupView() {
        headerView.backgroundColor = organisationColours.secondaryBgColour
        orgNameLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        orgNameLabel.textColor = organisationColours.textColourFromSecondaryColour
        nameLabel.font = UIFont.openSansFontOfSize(size: 14)
        nameLabel.textColor = organisationColours.textColourFromSecondaryColour
        nameLabel.alpha = 0.8
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        tableView.backgroundColor = UIColor.white
        
        let swapOrgImage = UIImage(named: "icSwapOrganisation")?.withRenderingMode(.alwaysTemplate)
        swapOrgBtn.setImage(swapOrgImage, for: .normal)
        swapOrgBtn.tintColor = organisationColours.textColourFromSecondaryColour
        let settingsImage = UIImage(named: "icMenuSettings")?.withRenderingMode(.alwaysTemplate)
        settingsBtn.setImage(settingsImage, for: .normal)
        settingsBtn.tintColor = organisationColours.textColourFromSecondaryColour
        
        notificationCountView.layer.cornerRadius = notificationCountView.frame.size.width/2
        notificationCountView.clipsToBounds = true
        
       
    }
    
    @objc func setOtherAppNotificationCount(notification: NSNotification){
        if let count = notification.userInfo?["count"] as? Int {
            if(count < 1){
                notificationCountView.isHidden = true
            }
            else{
                notificationCountView.isHidden = false
                notificationCountLabel.text = "\(count)"
            }
        }
    }
    
    
    func setOtherAppNotificationCountFromStorage(){
        let otherAppUnreadCount = UserDefaults.standard.string(forKey: "otherAppUnreadCount")
        var count = otherAppUnreadCount
        
        if(count !=  "" && count != "0"){
            notificationCountView.isHidden = false
            notificationCountLabel.text = count
        }
        else{
            notificationCountView.isHidden = true   
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .left)

        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            menuState: menuState){
                self.dismiss(animated: true, completion: nil)
        }
    }
        
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swapOrgBtnPressed(_ sender: Any) {
        presenter?.swapOrgBtnPressed()
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any) {
        presenter?.settingsBtnPressed()
    }
    
    @IBAction func logoBtnPressed(_ sender: Any) {
        presenter?.logoBtnPressed()
    }
    
    @IBAction func orgNameBtnPressed(_ sender: Any) {
        presenter?.orgNameBtnPressed()
    }
    
    func setSelectedMenuEntry(entry: NavigationEntry) {
        self.selectedMenuEntry = entry
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = menuEntries.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuEntry = menuEntries[indexPath.row]
        let isSelected = selectedMenuEntry?.id == menuEntry.id ? true : false
        let isOpen = isMenuEntryOpen(id: menuEntry.id ?? 0, checkChildren: false)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuEntryCell", for: indexPath) as! MenuEntryCell
        cell.organisationColours = self.organisationColours
        cell.configure(menuEntry: menuEntry, selected: isSelected, isOpen: isOpen)
        cell.delegate = self
        
        if let url = menuEntry.url, url.contains("user_messages") {
            var totalNum = UserDefaults.standard.string(forKey: "UpdateCount")
            var otherOrgNum = UserDefaults.standard.string(forKey: "otherAppUnreadCount")
            cell.toggleUnreadCount(count: (Int(totalNum ?? "0") ?? 0) - (Int(otherOrgNum ?? "0") ?? 0))
        } else {
            cell.hideUnreadCount()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let menuEntry = menuEntries[indexPath.row]
        
        if let level = menuEntry.level, level == 0 {
            //Always show top level
            return 48
        }
        
        guard let id = menuEntry.id else { return 0 }
        if isMenuEntryOpen(id: id) {
            return 48
        }
        
        return 0
    }
}

extension MenuViewController: MenuView {
    func setMenuEntries(menuEntries: Array<NavigationEntry>) {
        self.menuEntries = menuEntries
    }
    
    func setUserAvatarPlaceholder() {
        profileImageView.image = UIImage(named: "icUserIconPlaceholder")
    }
    
    func setUserImage(url: String) {
        if let imageUrl = URL(string: url) {
            profileImageView.kf.setImage(with: imageUrl, placeholder: ImagePlaceholderView(), options: [.transition(.fade(0.2))])
        } else {
            setUserAvatarPlaceholder()
        }
    }
    
    func setUserName(name: String) {
        nameLabel.text = name
    }
    
    func setOrganisationImage(url: String) {
        if let imageUrl = URL(string: url) {
            orgLogoImageView.kf.setImage(with: imageUrl, placeholder: ImagePlaceholderView(), options: [.transition(.fade(0.2))]) { result in
                switch result {
                case .success:
                    self.leftAlignLogoImageView()
                default:
                    break
                }
            }
        }
    }
    
    func setOrganisationName(name: String) {
        orgNameLabel.text = name
    }
    
    func refreshMenuRows(rows: Array<Int>) {
        refreshItems(rows: rows)
    }
    
    func setOpenEntries(openEntries: Set<NavigationEntry>) {
        self.openEntries = openEntries
        menuActionDelegate?.saveOpenMenuSections(openEntries: openEntries)
    }
    
    func toggleSwitchOrganisationsBtn(show: Bool) {
        switch show {
        case true:
            swapOrgBtnWrapper.isHidden = false
        case false:
            swapOrgBtnWrapper.isHidden = true
        }
    }
    
    func didSelectMenuEntry(menuEntry: NavigationEntry) {
        self.selectedMenuEntry = menuEntry
        tableView.reloadData()
        
        menuActionDelegate?.openNavigationEntry(menuEntry: menuEntry)
    }
    
    func clearSelectedMenuEntry() {
        self.selectedMenuEntry = nil
        tableView.reloadData()
        
        menuActionDelegate?.clearSelectedMenuEntry()
    }
    
    func gotoSettings() {
        menuActionDelegate?.gotoSettings()
    }
    
    func sendSwapOrgEvent() {
        menuActionDelegate?.swapOrgPressed()
    }
    
    func setupBasketButton(count: Int) {
        if let oldBasketView = self.basketIconView {
            oldBasketView.removeFromSuperview()
        }
        
        let tintColour = organisationColours.textColourFromSecondaryColour
        self.basketIconView = BasketIconView(count: count, tintColour: tintColour, basketPressed: { [weak self] () in
            guard let weakSelf = self else { return }
            weakSelf.presenter?.basketButtonPressed()
        })
        basketIconView!.translatesAutoresizingMaskIntoConstraints = false
        basketWrapper.addSubview(basketIconView!)
        basketIconView!.centerXAnchor.constraint(equalTo: basketWrapper.centerXAnchor).isActive = true
        basketIconView!.centerYAnchor.constraint(equalTo: basketWrapper.centerYAnchor).isActive = true
        
        if(count < 1 || count == nil){
            basketWrapper.isHidden = true
        }
        else {
            basketWrapper.isHidden = false
        }
    }
    
    func gotoCart() {
        menuActionDelegate?.gotoCart()
    }
    
    func gotoLandingPage() {
        menuActionDelegate?.gotoLandingPage()
    }
    
    func updateUnreadNotificationsCount(count: Int) {
        self.unreadNotificationsOrgCount = count
        tableView.reloadData()
    }
}

extension MenuViewController: MenuEntryCellDelegate {
    func didPressPage(menuEntry: NavigationEntry) {
        presenter?.didPressPage(menuEntry: menuEntry)
    }
    
    func didPressDropdown(menuEntry: NavigationEntry) {
        presenter?.didPressDropdown(menuEntry: menuEntry)
    }
}

extension MenuViewController {
    func refreshItems(rows: Array<Int>) {
        CATransaction.begin()
        tableView.beginUpdates()
        
        for row in rows {
            tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
        
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func isMenuEntryOpen(id: Int, checkChildren: Bool = true) -> Bool {
        return openEntries.contains { (navigationEntry) -> Bool in
            if navigationEntry.id == id {
                return true
            }
            if checkChildren {
                if let childEntries = navigationEntry.entries {
                    return childEntries.contains(where: { (childNavigationEntry) -> Bool in
                        if childNavigationEntry.id == id {
                            return true
                        }
                        return false
                    })
                }
            }
            return false
        }
    }
}

extension MenuViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch organisationColours.statusBarStyleFromSecondaryColour {
        case .light:
            return .lightContent
        case .dark:
            return .default
        }
    }
}

extension MenuViewController {
    fileprivate func leftAlignLogoImageView() {
        guard let logoImage = orgLogoImageView.image else { return }
        let imageViewHeight = orgLogoImageView.bounds.height
        let imageViewWidth = orgLogoImageView.bounds.width
        let imageSize = logoImage.size
        let scaledImageWidth = min(imageSize.width * (imageViewHeight / imageSize.height), imageViewWidth)
        
        //Adjust image view left constraint to left align the image with it still aspect fit
        let inset = (orgLogoImageView.frame.width - scaledImageWidth) / 2
        orgLogoImageViewLeftConstraint.constant = 16 - inset
    }
}
