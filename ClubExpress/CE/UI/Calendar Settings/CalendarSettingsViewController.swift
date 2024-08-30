//
//  CalendarSettingsViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol CalendarSettingsDelegate: class {
    func calendarSettingsDidChange()
}

class CalendarSettingsViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var presenter: CalendarSettingsPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate var calendars = Array<OrgCalendar>()
    weak var delegate: CalendarSettingsDelegate?
    fileprivate var emptyPlaceholderView: EmptyPlaceholder?
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAppActiveNotification()
        
        presenter?.viewDidLoad()
    }
    
    deinit {
        removeAppActiveNotification()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1.0)

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }

    @IBAction func closeBtnPressed(_ sender: Any) {
        presenter?.closeBtnPressed()
    }
    
    fileprivate func setupAppActiveNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func removeAppActiveNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appDidBecomeActive(notification: Notification) {
        presenter?.appDidBecomeActive()
    }
}

extension CalendarSettingsViewController: CalendarSettingsView {
    func setCalendars(calendars: Array<OrgCalendar>) {
        self.calendars = calendars
        tableView.reloadData()
    }
    
    func replaceCalendar(index: Int, calendar: OrgCalendar) {
        self.calendars[index] = calendar
    }
    
    func closePopup() {
        dismiss(animated: true, completion: nil)
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
    
    func sendCalendarSettingsDidChange() {
        delegate?.calendarSettingsDidChange()
    }
    
    func showCalendarPermissionsError() {
        tableView.reloadData()
        
        showAlertPopup(title: "Calendar Permission Error", message: "There was an error checking calendar subscriptions. Please check permission granted in device settings.")
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
}

extension CalendarSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calendar = calendars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSettingsItemCell", for: indexPath) as! CalendarSettingsItemCell
        cell.delegate = self
        cell.organisationColours = self.organisationColours
        cell.configure(calendar: calendar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CalendarSettingsViewController: CalendarSettingsItemCellDelegate {
    func toggleSwitched(calendar: OrgCalendar, enabled: Bool) {
        presenter?.calendarToggled(calendar: calendar, enabled: enabled)
    }
    
    func subscribeBtnPressed(calendar: OrgCalendar) {
        presenter?.subscribeBtnPressed(calendar: calendar)
    }
}
