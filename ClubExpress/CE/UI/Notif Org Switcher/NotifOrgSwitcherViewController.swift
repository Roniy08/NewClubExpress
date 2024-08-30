//
//  NotifOrgSwitcherViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 26/03/2019.
//  
//

import UIKit

class NotifOrgSwitcherViewController: UIViewController {

    var presenter: NotifOrgSwitcherPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    var receivedNotification: ReceivedNotification? {
        didSet {
            presenter?.receivedNotification = receivedNotification
        }
    }
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.viewDidLoad()
        
        setupView()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor.mtBrightWhite
        loadingSpinner.color = UIColor.white
    }
}

extension NotifOrgSwitcherViewController: NotifOrgSwitcherView {
    func gotoOrganisationWrapperAndPresentNotifiction(notification: ReceivedNotification) {
        guard let organisationWrapperVC = storyboard?.instantiateViewController(withIdentifier: "organisationWrapperVC") as? OrganisationWrapperViewController else { return }
        organisationWrapperVC.deferredReceivedNotification = notification
        
        guard let appDelegate = UIApplication.shared.delegate else { return }
        appDelegate.window??.rootViewController = organisationWrapperVC
        appDelegate.window??.makeKeyAndVisible()        
    }
    
    func showErrorSwitchingOrganisation() {
        let errorVC = UIAlertController(title: "Error Switching Organization", message: "There was an error switching organization.", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.presenter?.retrySwitchOrgBtnPressed()
        }
        errorVC.addAction(retryAction)
        let logoutAction = UIAlertAction(title: "Dismiss", style: .destructive) { (action) in
            self.presenter?.dismissBtnPressed()
        }
        errorVC.addAction(logoutAction)
        errorVC.preferredAction = retryAction
        present(errorVC, animated: true, completion: nil)
    }
    
    func changeToSplashVC() {
        guard let splashVC = storyboard?.instantiateViewController(withIdentifier: "splashVC") as? SplashViewController else { return }
        guard let appDelegate = UIApplication.shared.delegate else { return }
        appDelegate.window??.rootViewController = splashVC
        splashVC.view.backgroundColor = UIColor.white
        appDelegate.window??.makeKeyAndVisible()
    }
}

extension NotifOrgSwitcherViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
