//
//  CalendarViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import Foundation

class CalendarViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var presenter: CalendarPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate var selectedMonth: Date?
    fileprivate var selectedDay: Date?
    fileprivate var calendarGridVC: CalendarGridViewController?
    fileprivate var swipeLeftGesture: UISwipeGestureRecognizer?
    fileprivate var swipeRightGesture: UISwipeGestureRecognizer?
    fileprivate var selectedDateHeaderString: String?
    fileprivate var selectedDayEvents = Array<CalendarEvent>()
    fileprivate var showEmptyCell = false
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var ads = Array<NativeAd>()
    weak var delegate: CalendarDelegate?
    
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var nextMonthBtn: UIButton!
    @IBOutlet weak var previousMonthBtn: UIButton!
    @IBOutlet weak var monthBarWrapper: UIView!
    @IBOutlet weak var eventsLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red;
        setupView()
        addPullToRefresh()
        addSwipeGestures()
        self.toolbarItems = []
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeTableViewHeaderHeight()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)

        monthBarWrapper.backgroundColor = organisationColours.primaryBgColour
        todayBtn.setTitleColourForAllStates(colour: organisationColours.tintColour)
        todayBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 15)
        
        currentDateLabel.textColor = organisationColours.tintColour
        currentDateLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        
        eventsLoadingIndicator.color = organisationColours.textColour
        
        previousMonthBtn.tintColor = organisationColours.tintColour
        nextMonthBtn.tintColor = organisationColours.tintColour
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calendarSettingsNC = segue.destination as? OrganisationNavigationController {
            if let calendarSettingsVC = calendarSettingsNC.viewControllers.first as? CalendarSettingsViewController {
                calendarSettingsVC.delegate = self
            }
        } else if let calendarGridVC = segue.destination as? CalendarGridViewController {
            calendarGridVC.view.translatesAutoresizingMaskIntoConstraints = false
            calendarGridVC.delegate = self
            self.calendarGridVC = calendarGridVC
        }
    }
    
    fileprivate func addSwipeGestures() {
        swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(viewSwipedLeft))
        swipeLeftGesture?.direction = .left
        view?.addGestureRecognizer(swipeLeftGesture!)
        
        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(viewSwipedRight))
        swipeRightGesture?.direction = .right
        view?.addGestureRecognizer(swipeRightGesture!)
    }
    
    fileprivate func resizeTableViewHeaderHeight() {
        if let tableViewHeader = tableView.tableHeaderView {
            tableViewHeader.layoutIfNeeded()
            let size = tableViewHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let newHeight = size.height
            tableViewHeader.frame.size.height = newHeight
            tableView.tableHeaderView = tableViewHeader
            tableView.layoutIfNeeded()
        }
    }
    
    fileprivate func addPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func pulledToRefresh(control: UIRefreshControl) {
        presenter?.pulledToRefresh()
    }
    
    @objc func viewSwipedLeft(gesture: UISwipeGestureRecognizer) {
        presenter?.viewSwipedLeft()
    }
    
    @objc func viewSwipedRight(gesture: UISwipeGestureRecognizer) {
        presenter?.viewSwipedRight()
    }
    
    @IBAction func todayBtnPressed(_ sender: Any) {
        presenter?.todayBtnPressed()
    }
    
    @IBAction func nextMonthBtnPressed(_ sender: Any) {
        presenter?.nextMonthBtnPressed()
    }
    
    @IBAction func previousMonthBtnPressed(_ sender: Any) {
        presenter?.previousMonthBtnPressed()
    }
    
   
}

extension CalendarViewController: CalendarView {
    
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
    
    func setCurrentMonthLabel(text: String) {
        currentDateLabel.text = text
    }
    
    func toggleTodayBtn(enabled: Bool) {
        todayBtn.isEnabled = enabled
        todayBtn.alpha = enabled ? 1 : 0.2
    }
    
    func setSelectedMonth(date: Date) {
        self.selectedMonth = date
        calendarGridVC?.selectedMonth = date
    }
    
    func setSelectedDay(date: Date) {
        self.selectedDay = date
        calendarGridVC?.selectedDay = date
    }
    
    func eventsUpdatedRefreshGrid() {
        //refresh grid and events view to update events
        calendarGridVC?.eventsUpdated()
    }
    
    func toggleEventsLoadingIndicator(show: Bool) {
        switch show {
        case true:
            eventsLoadingIndicator.startAnimating()
        case false:
            eventsLoadingIndicator.stopAnimating()
        }
    }
 
    func setSelectedDayEvents(events: Array<CalendarEvent>) {
        self.selectedDayEvents = events
        tableView.reloadData()
    }
    
    func setSelectedDateHeaderString(dateString: String) {
        selectedDateHeaderString = dateString
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleEmptyCell(show: Bool) {
        showEmptyCell = show
        tableView.reloadData()
    }
    
    func toggleTableViewAlwaysBounce(bounce: Bool) {
        tableView.alwaysBounceVertical = bounce
    }
    
    func showErrorGettingCalendarsPopup() {
        showAlertPopup(title: "Calendars Error", message: "There was an error loading calendars")
    }
    
    func showErrorGettingEventsPopup() {
        showAlertPopup(title: "Events Error", message: "There was an error loading events")
    }
    
    func presentEventPopup(event: CalendarEvent) {
        if let calendarEventVC = storyboard?.instantiateViewController(withIdentifier: "calendarEventVC") as? CalendarEventViewController {
            calendarEventVC.modalPresentationStyle = .overFullScreen
            calendarEventVC.event = event
            calendarEventVC.organisationColours = self.organisationColours
            calendarEventVC.delegate = self
            navigationController?.present(calendarEventVC, animated: false, completion: nil)
        }
    }
    
    func toggleSeperatorLine(show: Bool) {
        if show == true {
            tableView.separatorStyle = .singleLine
        } else {
            tableView.separatorStyle = .none
        }
    }
    
    func endRefreshControlAnimating() {
        refreshControl.endRefreshing()
    }
    
    func sendEventToChangePageToWebContent(url: String) {
        delegate?.gotoWebContent(url: url)
    }
}

extension CalendarViewController: CalendarSettingsDelegate {
    func calendarSettingsDidChange() {
        presenter?.calendarSettingsDidChange()
    }
}

extension CalendarViewController: CalendarGridDelegate {
    func selectedDayDidChange(day: Date) {
        presenter?.selectedDayDidChange(day: day)
    }
    
    func sizeDidChange() {
        resizeTableViewHeaderHeight()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showEmptyCell {
            return 1
        }
        return selectedDayEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showEmptyCell {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventsEmptyCell", for: indexPath) as! CalendarEventsEmptyCell
            return emptyCell
        } else {
            let event = selectedDayEvents[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell", for: indexPath) as! CalendarEventCell
            cell.configure(event: event)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if showEmptyCell {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showEmptyCell {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectEvent(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventsHeaderCell") as! CalendarEventsHeaderCell
        headerCell.configure(dateString: selectedDateHeaderString ?? "")
        return headerCell
    }
}

extension CalendarViewController: CalendarEventDelegate {
    func openUrlInWebContent(url: String) {
        presenter?.openUrlInWebContent(url: url)
    }
}
