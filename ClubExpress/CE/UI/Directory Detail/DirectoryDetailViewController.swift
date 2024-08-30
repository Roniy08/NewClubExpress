//
//  DirectoryDetailViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import ContactsUI

protocol DirectoryDetailDelegate: class {
    func didChangeFavourited()
}

class DirectoryDetailViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var entryID: String!
    var entryName: String!
    var ads = Array<NativeAd>()
    var presenter: DirectoryDetailPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var sections = Array<DirectoryEntrySection>()
    fileprivate var headerLabels: DirectoryEntryLabels?
    weak var delegate: DirectoryDetailDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollBtn: UIButton!
    
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var bottomAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addPullToRefresh()
        
        presenter?.viewDidLoad(entryID: entryID, entryName: entryName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDisappear()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 450
        tableView.estimatedSectionHeaderHeight = 40
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0
        var emptyFrame = CGRect.zero
        emptyFrame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: emptyFrame)
        tableView.tableFooterView = UIView(frame: emptyFrame)
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }
    
    fileprivate func addPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func pulledToRefresh(control: UIRefreshControl) {
        presenter?.pulledToRefresh()
    }
    
    @IBAction func scrollBtnPressed(_ sender: Any) {
        presenter?.scrollBtnPressed()
    }
    
    fileprivate func getNextIndex(currentIndexPath: IndexPath) -> IndexPath {
        var nextRow = 0
        var nextSection = 0
        var iteration = 0
        var startRow = currentIndexPath.row
        for section in currentIndexPath.section ..< tableView.numberOfSections {
            nextSection = section
            for row in startRow ..< tableView.numberOfRows(inSection: section) {
                nextRow = row
                iteration += 1
                if iteration == 2 {
                    let nextIndexPath = IndexPath(row: nextRow, section: nextSection)
                    return nextIndexPath
                }
            }
            startRow = 0
        }
        return currentIndexPath
    }
    
    @objc func unfavouriteEntryPressed(barButton: UIBarButtonItem) {
        presenter?.unfavouriteEntryPressed()
    }
    
    @objc func favouriteEntryPressed(barButton: UIBarButtonItem) {
        presenter?.favouriteEntryPressed()
    }
}

extension DirectoryDetailViewController: DirectoryDetailView {
    
    func showAds(ads: Array<NativeAd>) {
        
        for ad in ads {
            if(ad.position != "" && ad.position != nil){
                if(ad.position!.contains("top")){
                    let url = ad.imgSrc
                    if(url != nil && url != ""){
                    self.topAdImageView.kf.setImage(with: URL(string: url!))
                        let width =  ad.adWidth ?? 720
                        let height =  ad.height ?? 90
                        let ratio = width / height
                        let newHeight = UIScreen.main.bounds.size.width / CGFloat(ratio)
                        self.topAdHeightConstraint.constant = newHeight
                        topAdImageView.layoutIfNeeded()

                        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(topAdTapped))
                        topAdImageView.addGestureRecognizer(tapGestureRecognizer)
                        topAdImageView.isUserInteractionEnabled = true

                }
                    
        }
                else  if(ad.position!.contains("bottom")){
                    let url = ad.imgSrc
                    if(url != nil && url != ""){
                    self.bottomAdImageView.kf.setImage(with: URL(string: url!))
                        let width =  ad.adWidth ?? 720
                        let height =  ad.height ?? 90
                        let ratio = width / height
                        let newHeight = UIScreen.main.bounds.size.width / CGFloat(ratio)
                        self.bottomAdHeightConstraint.constant = newHeight
                        bottomAdImageView.layoutIfNeeded()
                        
                        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bottomAdTapped))
                        bottomAdImageView.addGestureRecognizer(tapGestureRecognizer)
                        bottomAdImageView.isUserInteractionEnabled = true
                }
        }

        self.ads = ads
        }
      }
    }
    
    @objc func topAdTapped(sender:UITapGestureRecognizer) {
            for ad in ads {
                if(ad.position != "" && ad.position != nil){
                    if(ad.position!.contains("top")){
                        if let url = URL(string: ad.href ?? "") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                }
                
            }
        }
        
        
        @objc func bottomAdTapped(sender:UITapGestureRecognizer) {
            for ad in ads {
                if(ad.position != "" && ad.position != nil){
                    if(ad.position!.contains("bottom")){
                        if let url = URL(string: ad.href ?? "") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                }
                
            }
        }
    
    
    func setEntrySections(sections: Array<DirectoryEntrySection>) {
        self.sections = sections
        tableView.reloadData()
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        switch loading {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
    }
    
    func showErrorLoadingDirectoryEntryPopup(message: String) {
        showAlertPopup(title: "Error Loading Entry", message: message)
    }
    
    func showErrorFavouritingEntryPopup(message: String) {
        showAlertPopup(title: "Error Favoriting Entry", message: message)
    }
    
    func endRefreshControlAnimating() {
        refreshControl.endRefreshing()
    }
    
    func setHeaderLabels(labels: DirectoryEntryLabels) {
        self.headerLabels = labels
    }
    
    func showPhoneActionSheet(number: String, sourceView: DirectoryFieldView, sourceFrame: CGRect) {
        let phoneActionSheet = UIAlertController(title: "\(number)", message: "Do you want to call or message this number?", preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "Call", style: .default) { (action) in
            self.presenter?.callPhoneNumberActionPressed(number: number)
        }
        phoneActionSheet.addAction(callAction)
        let messageAction = UIAlertAction(title: "Message", style: .default) { (action) in
            self.presenter?.messagePhoneNumberActionPressed(number: number)
        }
        phoneActionSheet.addAction(messageAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        phoneActionSheet.addAction(cancelAction)
        
        let sourceRect = sourceView.convert(sourceFrame, to: view)
        phoneActionSheet.popoverPresentationController?.sourceRect = sourceRect
        phoneActionSheet.popoverPresentationController?.sourceView = view
        
        present(phoneActionSheet, animated: true, completion: nil)
    }
    
    func showMapsActionSheet(address: String, sourceView: DirectoryFieldView, sourceFrame: CGRect) {
        let addressFormatted = address.replacingOccurrences(of: "\n", with: " ")
        let mapsActionSheet = UIAlertController(title: "\(addressFormatted)", message: "Which maps application do you want to open this address in?", preferredStyle: .actionSheet)
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            self.presenter?.openAppleMapsActionPressed(address: address)
        }
        mapsActionSheet.addAction(appleMapsAction)
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            self.presenter?.openGoogleMapsActionPressed(address: address)
        }
        mapsActionSheet.addAction(googleMapsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        mapsActionSheet.addAction(cancelAction)
        
        mapsActionSheet.popoverPresentationController?.sourceRect = sourceView.convert(sourceFrame, to: view)
        mapsActionSheet.popoverPresentationController?.sourceView = view
        
        present(mapsActionSheet, animated: true, completion: nil)
    }
    
    func openSystemUrl(url: String) {
        if let systemUrl = URL(string: url) {
            if (UIApplication.shared.canOpenURL(systemUrl)) {
                UIApplication.shared.open(systemUrl, options: [:], completionHandler: nil)
            } else {
                print("can't open url: \(systemUrl.absoluteString)")
            }
        }
    }
    
    func scrollToNextPerson() {
        let visibleCells = tableView.visibleCells
        let lowerVisibleCells = visibleCells.filter { (cell) -> Bool in
            //Ignore cells that are right on the top edge from content inset
            let cellBottomY = cell.frame.origin.y + cell.frame.size.height
            let contentOffset = tableView.contentOffset.y
            let contentInsetTop = tableView.contentInset.top
            
            if cellBottomY - contentOffset > contentInsetTop {
                return true
            } else {
                return false
            }
        }
        
        guard let firstVisibleCell = lowerVisibleCells.first else { return }
        guard let firstVisibleIndex = tableView.indexPath(for: firstVisibleCell) else { return }
        
        let nextIndex = getNextIndex(currentIndexPath: firstVisibleIndex)
        let newRowPosition = nextIndex.row == 0 ? NSNotFound : nextIndex.row
        tableView.scrollToRow(at: IndexPath(row: newRowPosition, section: nextIndex.section), at: .top, animated: true)
    }
    
    func toggleScrollBtn(visible: Bool) {
        scrollBtn.isHidden = !visible
        scrollBtn.isEnabled = visible
    }
    
    func showAddContactPopup(contact: CNMutableContact) {
        let contactStore = CNContactStore()
        
        let addContactVC = CNContactViewController(forNewContact: contact)
        addContactVC.delegate = self
        addContactVC.contactStore = contactStore
        let addContactNC = UINavigationController(rootViewController: addContactVC)
        present(addContactNC, animated: true, completion: nil)
    }
    
    func toggleIsFavouritedButton(favourited: Bool) {
        switch favourited {
        case true:
            let unFavouriteBtn = UIBarButtonItem(image: UIImage(named: "icFavourited"), style: .plain, target: self, action: #selector(unfavouriteEntryPressed))
            navigationItem.rightBarButtonItem = unFavouriteBtn
        case false:
            let favouriteBtn = UIBarButtonItem(image: UIImage(named: "icFavourite"), style: .plain, target: self, action: #selector(favouriteEntryPressed))
            navigationItem.rightBarButtonItem = favouriteBtn
        }
    }
    
    func sendDidChangeFavourited() {
        delegate?.didChangeFavourited()
    }
}

extension DirectoryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return section.people?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let person = section.people![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryDetailPersonCell", for: indexPath) as! DirectoryDetailPersonCell
        cell.delegate = self
        cell.organisationColours = self.organisationColours
        cell.configure(person: person, sectionHeaderLabel: section.headerLabel, otherLabels: headerLabels)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        let header = tableView.dequeueReusableCell(withIdentifier: "DirectoryDetailHeaderCell") as! DirectoryDetailHeaderCell
        header.configure(label: section.headerLabel)
        return header
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension DirectoryDetailViewController: DirectoryDetailPersonCellDelegate {
    func didPressField(fieldView: DirectoryFieldView, field: DirectoryEntryField, sourceFrame: CGRect) {
        presenter?.didPressField(fieldView: fieldView, field: field, sourceFrame: sourceFrame)
    }
    
    func didPressAddContact(person: DirectoryEntryPerson, imageData: Data?) {
        presenter?.didPressAddContact(person: person, imageData: imageData)
    }
}

extension DirectoryDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollOffset = tableView.contentSize.height - tableView.frame.size.height
        presenter?.tableViewDidScroll(offset: scrollView.contentOffset.y, maxScrollOffset: maxScrollOffset)
    }
}

extension DirectoryDetailViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.navigationController?.dismiss(animated: true, completion: nil)
    }
}
