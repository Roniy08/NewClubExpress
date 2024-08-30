//
//  DirectoryFiltersViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol DirectoryFiltersDelegate: class {
    func filtersDidChange()
}

class DirectoryFiltersViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var presenter: DirectoryFiltersPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate var filters = Array<DirectoryFilter>()
    fileprivate var appliedFilters = Array<DirectoryAppliedFilter>()
    fileprivate var tableViewFooterView: UIView?
    fileprivate var viewTapGesture: UITapGestureRecognizer?
    weak var delegate: DirectoryFiltersDelegate?
    
    @IBOutlet weak var closeBarBtn: UIBarButtonItem!
    @IBOutlet weak var applyWrapper: UIView!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var clearAllFiltersBtn: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearAllFiltersWrapper: UIView!
    
    var priorityCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
       
        presenter?.viewDidLoad()
    }
    
 
    
    fileprivate func setupView() {
        view.backgroundColor = organisationColours.primaryBgColour
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.tableFooterView = UIView()
        tableView.delegate = self

        applyWrapper.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        applyBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        applyBtn.setTitleForAllStates(title: "Apply")
        applyBtn.setTitleColourForAllStates(colour: UIColor.white)
        
        clearAllFiltersBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 15)
        clearAllFiltersBtn.setTitleForAllStates(title: "Clear All Filters")
        clearAllFiltersBtn.setTitleColourForAllStates(colour: organisationColours.textColour)
        
        tableViewFooterView = tableView.tableFooterView
        
        loadingIndicator.color = organisationColours.tintColour
        
        addViewTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func closeBarBtnPressed(_ sender: Any) {
        presenter?.closeBarBtnPressed()
    }
    
    @IBAction func applyBtnPressed(_ sender: Any) {
        presenter?.applyBtnPressed()
    }
    
    @IBAction func clearAllFiltersBtnPressed(_ sender: Any) {
        presenter?.clearAllFiltersBtnPressed()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        view.layoutIfNeeded()
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt

            let inset = keyboardSize.height - applyWrapper.frame.height - clearAllFiltersWrapper.frame.height
            tableViewBottomConstraint.constant = inset
            
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
    
    fileprivate func addViewTapGesture() {
        viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGesturePressed))
        view.addGestureRecognizer(viewTapGesture!)
    }
    
    @objc func viewTapGesturePressed(tapGesure: UITapGestureRecognizer) {
        presenter?.viewTapGesturePressed()
    }
}

extension DirectoryFiltersViewController: DirectoryFiltersView {
    func showErrorLoadingFiltersPopup(message: String) {
        showAlertPopup(title: "Error Loading Filters", message: message)
    }
    
    func closePopup() {
        dismiss(animated: true, completion: nil)
    }
    
    func setFilters(filters: Array<DirectoryFilter>) {
        self.filters = filters
    }
    
    func setAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>) {
        self.appliedFilters = appliedFilters
    }
    
    func prepareFilters(){
        var priorityFilters = Array<DirectoryFilter>()
        var normalFilters = Array<DirectoryFilter>()
        
        for filter in filters {
            if(filter.name!.contains("__")){
                priorityFilters.append(filter)
            }
            else{
                normalFilters.append(filter)
            }
        }
        
        priorityCount = priorityFilters.count
        filters = []
        filters = priorityFilters + normalFilters
        print(filters)
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        switch loading {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
    }
    
    func toggleClearAllFiltersBtn(show: Bool) {
        switch show {
        case true:
            clearAllFiltersWrapper.isHidden = false
        case false:
            clearAllFiltersWrapper.isHidden = true
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func reloadTableViewRow(index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    func showCloseConfirmPopup() {
        let alertVC = UIAlertController(title: "Cancel Changes?", message: "You have changed filters. Are you sure you want to cancel these changes?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.presenter?.closePopupConfirmed()
        }
        alertVC.addAction(yes)
        let no = UIAlertAction(title: "No", style: .default) { (action) in
        }
        alertVC.addAction(no)
        alertVC.preferredAction = no
        present(alertVC, animated: true, completion: nil)
    }
    
    func dismissPickerViews() {
        view?.endEditing(true)
    }
    
    func sendFiltersDidChange() {
        delegate?.filtersDidChange()
    }
}

extension DirectoryFiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filters.count == 0){
            return 0
        }
        else{
            return filters.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < priorityCount){
            let filter = filters[indexPath.row]
            let selectedFilter: DirectoryAppliedFilter? = self.appliedFilters.first { (appliedFilter) -> Bool in
                return appliedFilter.filter?.name == filter.name
            }
            let selectedFilterOption = selectedFilter?.selectedOption
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryFilterCell", for: indexPath) as! DirectoryFilterCell
            cell.organisationColours = self.organisationColours
            cell.configure(filter: filter, selectedOption: selectedFilterOption)
            cell.delegate = self
            return cell
        }
        else if(indexPath.row > priorityCount){
            let filter = filters[indexPath.row - 1]
            let selectedFilter: DirectoryAppliedFilter? = self.appliedFilters.first { (appliedFilter) -> Bool in
                return appliedFilter.filter?.name == filter.name
            }
            let selectedFilterOption = selectedFilter?.selectedOption
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryFilterCell", for: indexPath) as! DirectoryFilterCell
            cell.organisationColours = self.organisationColours
            cell.configure(filter: filter, selectedOption: selectedFilterOption)
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryDividerCell", for: indexPath) as! DirectoryDividerCell
                return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == priorityCount){
            return 2
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
}

extension DirectoryFiltersViewController: DirectoryFilterCellDelegate {
    func didChangeFilterOption(filter: DirectoryFilter, option: DirectoryFilterOption?) {
        presenter?.didChangeFilterOption(filter: filter, option: option)
    }
}
