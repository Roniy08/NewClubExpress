//
//  DirectoryViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class DirectoryViewController: UIViewController {
    
    var organisationColours: OrganisationColours!
    var presenter: DirectoryPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    weak var delegate: DirectoryDelegate?

    fileprivate var entries = Array<DirectoryEntry>()
    fileprivate var ads = Array<NativeAd>()
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var emptyPlaceholderView: EmptyPlaceholder?
    fileprivate var filterBarBtn: UIBarButtonItem?
    fileprivate var favouriteBarBtn: UIBarButtonItem?
    fileprivate var filterIconView: FilterIconView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var appliedFiltersWrapper: UIView!
    @IBOutlet weak var appliedFiltersStackView: UIStackView!
    @IBOutlet weak var clearFiltersBtn: UIButton!
    @IBOutlet weak var appliedFiltersTitleLabel: UILabel!
    @IBOutlet weak var openAppliedFiltersBtn: UIButton!
    @IBOutlet weak var appliedFiltersIcon: UIImageView!
    
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var bottomAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addPullToRefresh()
        
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        presenter?.viewWillDisappear()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)
        
        searchView.backgroundColor = organisationColours.primaryBgColour
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = UIColor.white
        }
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mtMatteBlack]
        searchBar.tintColor = organisationColours.primaryBgColour
        
        searchBar.barTintColor = organisationColours.primaryBgColour
        searchBar.isTranslucent = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 78
        tableView.tableFooterView = UIView()
        
        appliedFiltersWrapper.backgroundColor = organisationColours.primaryBgColour.withAlphaComponent(0.8)
        appliedFiltersTitleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
        appliedFiltersTitleLabel.textColor = organisationColours.textColour
        clearFiltersBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
        clearFiltersBtn.setTitleColourForAllStates(colour: organisationColours.textColour)
        
        setupFilterBarBtn(showIndicator: false)
        setupFavouriteBarBtn(favouriteFiltered: false)
        
        let lightIcon = UIImage(named: "icActiveFiltersAppliedLight")
        let darkIcon = UIImage(named: "icActiveFiltersAppliedDark")
        appliedFiltersIcon.image = organisationColours.isPrimaryBgColourDark ? lightIcon : darkIcon
    }
    
    fileprivate func addPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    fileprivate func setNavigationBarButtons() {
        var buttons = Array<UIBarButtonItem>()
        if let filterBarBtn = self.filterBarBtn {
            buttons.append(filterBarBtn)
        }
        if let favouriteBarBtn = self.favouriteBarBtn {
            buttons.append(favouriteBarBtn)
        }
        navigationItem.rightBarButtonItems = buttons
    }
    
    @objc func pulledToRefresh(control: UIRefreshControl) {
        presenter?.pulledToRefresh()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        view.layoutIfNeeded()

        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            
            tableViewBottomConstraint.constant = -keyboardSize.height
            
            let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        tableViewBottomConstraint.constant = 0
        
        let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: curve), .beginFromCurrentState]
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func clearFiltersBtnPressed(_ sender: Any) {
        presenter?.clearFiltersBtnPressed()
    }
    
    @IBAction func openAppliedFiltersBtnPressed(_ sender: Any) {
        presenter?.openAppliedFiltersBtnPressed()
    }
    
    @objc func favouriteFilterBarBtnPressed(barButton: UIBarButtonItem) {
        presenter?.favouriteFilterBarBtnPressed()
    }
    
    @objc func removeFavouriteFilterBarBtnPressed(barButton: UIBarButtonItem) {
        presenter?.removeFavouriteFilterBarBtnPressed()
    }
}

extension DirectoryViewController: DirectoryView {
    
    func setEntries(entries: Array<DirectoryEntry>) {
        self.entries = entries
        tableView.reloadData()
    }
    
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
    
    func endRefreshControlAnimating() {
        refreshControl.endRefreshing()
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        switch loading {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
    }
    
    func showErrorLoadingDirectoryPopup(message: String) {
        showAlertPopup(title: "Error loading the directory", message: message)
    }
    
    func dismissSearchBar() {
        searchBar.resignFirstResponder()
    }
    
    func showEmptyPlaceholderView(title: String, message: String) {
        if emptyPlaceholderView == nil {
            emptyPlaceholderView = EmptyPlaceholder()
            emptyPlaceholderView!.frame = tableView.bounds
            
            tableView.backgroundView = emptyPlaceholderView!
        }
        emptyPlaceholderView!.title = title
        emptyPlaceholderView!.message = message
        emptyPlaceholderView!.updateText()
    }
    
    func removeEmptyPlaceholderView() {
        emptyPlaceholderView?.removeFromSuperview()
        emptyPlaceholderView = nil
        tableView.backgroundView = nil
    }
    
    func showFiltersModal() {
        if let directoryFiltersNC = storyboard?.instantiateViewController(withIdentifier: "directoryFiltersNC") as? OrganisationNavigationController {
            if let directoryFiltersVC = directoryFiltersNC.viewControllers.first as? DirectoryFiltersViewController {
                directoryFiltersVC.delegate = self
                present(directoryFiltersNC, animated: true, completion: nil)
            }
        }
    }
    
    func showAppliedFiltersView(appliedFilters: Array<DirectoryAppliedFilter>) {
        resetAppliedFiltersItems()
        appliedFiltersWrapper.isHidden = false
        
        let maxVisibleFilters = 3
        let moreThanMaxFilters = appliedFilters.count > maxVisibleFilters ? true : false
        let filtersToShow = moreThanMaxFilters ? Array(appliedFilters[0..<(maxVisibleFilters - 1)]) : appliedFilters
        
        for appliedFilter in filtersToShow {
            let filterName = appliedFilter.filter?.label ?? ""
            let filterOption = appliedFilter.selectedOption?.name ?? ""
            let filterText = "\(filterName) \(filterOption)"
            addChildLabelToAppliedFiltersStackView(text: filterText)
        }
        
        if moreThanMaxFilters {
            let remainingFilters = appliedFilters.count - (maxVisibleFilters - 1)
            let remainingText = "+ \(remainingFilters) More"
            addChildLabelToAppliedFiltersStackView(text: remainingText)
        }
    }
    
    func hideAppliedFiltersView() {
        resetAppliedFiltersItems()
        appliedFiltersWrapper.isHidden = true
    }
    
    func toggleFilterBtnIndicator(show: Bool) {
        setupFilterBarBtn(showIndicator: show)
    }
    
    func toggleFavouritesFilterBtn(filtered: Bool) {
        setupFavouriteBarBtn(favouriteFiltered: filtered)
    }
    
    fileprivate func addChildLabelToAppliedFiltersStackView(text: String) {
        let appliedFilterView = UIView()
        let filterLabel = UILabel()
        filterLabel.font = UIFont.openSansFontOfSize(size: 14)
        filterLabel.textColor = organisationColours.textColour
        filterLabel.text = text
        
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        appliedFilterView.addSubview(filterLabel)
        filterLabel.constraintToSuperView(superView: appliedFilterView)
        
        appliedFiltersStackView.addArrangedSubview(appliedFilterView)
    }
    
    fileprivate func resetAppliedFiltersItems() {
        appliedFiltersStackView.arrangedSubviews.forEach { (arrangedView) in
            appliedFiltersStackView.removeArrangedSubview(arrangedView)
            arrangedView.removeFromSuperview()
        }
    }
    
    fileprivate func setupFilterBarBtn(showIndicator: Bool) {
        let tintColour = organisationColours.tintColour
        self.filterIconView = FilterIconView(filtersApplied: showIndicator, tintColour: tintColour, filterPressed: { [weak self] () in
            guard let weakSelf = self else { return }
            weakSelf.presenter?.filtersBarBtnPressed()
        })
        self.filterBarBtn = UIBarButtonItem(customView: self.filterIconView!)
        
        setNavigationBarButtons()
    }
    
    fileprivate func setupFavouriteBarBtn(favouriteFiltered: Bool) {
        switch favouriteFiltered {
        case true:
            self.favouriteBarBtn = UIBarButtonItem(image: UIImage(named: "icFavourited"), style: .plain, target: self, action: #selector(removeFavouriteFilterBarBtnPressed))
        case false:
            self.favouriteBarBtn = UIBarButtonItem(image: UIImage(named: "icFavourite"), style: .plain, target: self, action: #selector(favouriteFilterBarBtnPressed))
        }
        setNavigationBarButtons()
    }
    
    func pushToDirectoryDetail(id: String, name: String) {
        if let directoryDetailVC = storyboard?.instantiateViewController(withIdentifier: "directoryDetailVC") as? DirectoryDetailViewController {
            directoryDetailVC.entryID = id
            directoryDetailVC.entryName = name
            directoryDetailVC.delegate = self
            navigationController?.pushViewController(directoryDetailVC, animated: true)
        }
    }
    
    func sendEventToChangePageToWebContent(url: String) {
        delegate?.gotoWebContentFromDirectory(url: url)
    }
}

extension DirectoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryEntryCell", for: indexPath) as! DirectoryEntryCell
        cell.configure(entry: entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectRow(row: indexPath.row)
    }
}

extension DirectoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        presenter?.searchBtnPressed(searchTerm: searchTerm)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchTerm = searchBar.text else { return }
        presenter?.searchTermDidChange(searchTerm: searchTerm)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.cancelSearchBtnPressed()
    }
}

extension DirectoryViewController: DirectoryFiltersDelegate {
    func filtersDidChange() {
        presenter?.filtersDidChange()
    }
}

extension DirectoryViewController: DirectoryDetailDelegate {
    func didChangeFavourited() {
        presenter?.directoryDidChangeFavourite()
    }
}
