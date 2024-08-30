//
//  CalendarEventViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import OverlayContainer

protocol CalendarEventDelegate: class {
    func openUrlInWebContent(url: String)
}

class CalendarEventViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var event: CalendarEvent? {
        didSet {
            presenter?.event = event
        }
    }
    var presenter: CalendarEventPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    var overlayController: OverlayContainerViewController?
    private var eventContentViewController: CalendarEventContentViewController?
    enum OverlayNotch: Int, CaseIterable {
        case closed, minimum, maximum
    }
    fileprivate var bgViewTapGesture: UITapGestureRecognizer?
    fileprivate var notchIndex = 0
    fileprivate var whiteGradientLayer: CAGradientLayer?
    weak var delegate: CalendarEventDelegate?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var whiteFadeView: UIView!
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var bottomAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupOverlay()
        addTapGesture()
        
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        overlayController?.moveOverlay(toNotchAt: 1, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteGradientLayer!.frame = whiteFadeView.bounds
    }
    
    fileprivate func setupView() {
        bgView.alpha = 0
        whiteFadeView.alpha = 0
        
        whiteGradientLayer = CAGradientLayer()
        whiteGradientLayer!.frame = whiteFadeView.bounds
        whiteGradientLayer!.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        whiteGradientLayer!.locations = [0, 1]
        whiteFadeView.layer.insertSublayer(whiteGradientLayer!, at: 0)
        whiteFadeView.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupOverlay() {
        if let calendarEventContentVC = storyboard?.instantiateViewController(withIdentifier: "calendarEventContentVC") as? CalendarEventContentViewController {
            calendarEventContentVC.delegate = self
            calendarEventContentVC.event = self.event
            calendarEventContentVC.organisationColours = self.organisationColours
            self.eventContentViewController = calendarEventContentVC
        }
        
        overlayController = OverlayContainerViewController(style: .rigid)
        overlayController!.delegate = self
        overlayController!.viewControllers = [eventContentViewController] as! [UIViewController]

        addChild(overlayController!)
        overlayView.addSubview(overlayController!.view)
        
        overlayController!.view.translatesAutoresizingMaskIntoConstraints = false
        overlayController!.view.topAnchor.constraint(equalTo: overlayController!.view.superview!.topAnchor, constant: 0).isActive = true
        overlayController!.view.bottomAnchor.constraint(equalTo: overlayController!.view.superview!.bottomAnchor, constant: 0).isActive = true
        overlayController!.view.leadingAnchor.constraint(equalTo: overlayController!.view.superview!.leadingAnchor, constant: 0).isActive = true
        overlayController!.view.trailingAnchor.constraint(equalTo: overlayController!.view.superview!.trailingAnchor, constant: 0).isActive = true
        
        overlayController!.didMove(toParent: self)
        
        //constraint white fade to top of content scroll view, so moves up to follow overlay
        whiteFadeView.topAnchor.constraint(greaterThanOrEqualTo: eventContentViewController!.scrollView.topAnchor).isActive = true
    }
    
    private func notchHeight(for notch: OverlayNotch, availableSpace: CGFloat) -> CGFloat {
        switch notch {
        case .closed:
            return 0
        case .maximum:
            return availableSpace - 20
        case .minimum:
            return 235
        }
    }
    
    fileprivate func animateDismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.alpha = 0
            self.whiteFadeView.alpha = 0
        }) { (completed) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    fileprivate func addTapGesture() {
        bgViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(bgViewTapped))
        bgViewTapGesture?.delegate = self
        view.addGestureRecognizer(bgViewTapGesture!)
    }
    
    @objc func bgViewTapped(gesture: UITapGestureRecognizer) {
        presenter?.bgViewTapped()
    }
    
    private func percent(forTranslation translation: CGFloat,
                       maximumHeight: CGFloat,
                       minimumHeight: CGFloat) -> CGFloat {
        return 1 - (maximumHeight - translation) / (maximumHeight - minimumHeight)
    }
    
    private func percent(forTranslation translation: CGFloat,
                       coordinator: OverlayContainerTransitionCoordinator) -> CGFloat {
        return percent(
            forTranslation: translation,
            maximumHeight: coordinator.height(forNotchAt: OverlayNotch.maximum.rawValue),
            minimumHeight: coordinator.height(forNotchAt: OverlayNotch.minimum.rawValue)
        )
    }
    
    fileprivate func configureWhiteFade(percent: CGFloat) {
        if notchIndex >= 1 {
            whiteFadeView.alpha = 1 - min(1, max(0, percent))
        }
    }
}

extension CalendarEventViewController: CalendarEventView {
    func animateInBgView() {
        self.bgView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = 0.35
        }
    }
    
    func decreaseOverlay() {
        let newNotchIndex = max(0, self.notchIndex - 1)
        overlayController?.moveOverlay(toNotchAt: newNotchIndex, animated: true)
    }
    
    func closeOverlay() {
        overlayController?.moveOverlay(toNotchAt: 0, animated: true)
    }
    
    func sendEventToOpenUrlInWebContent(url: String) {
        delegate?.openUrlInWebContent(url: url)
    }
}

extension CalendarEventViewController: OverlayContainerViewControllerDelegate {
    
    // MARK: - OverlayContainerViewControllerDelegate
    
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        let notch = OverlayNotch.allCases[index]
        return notchHeight(for: notch, availableSpace: availableSpace)
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (overlayViewController as? CalendarEventContentViewController)?.scrollView
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
                                        at point: CGPoint,
                                        in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let header = (overlayViewController as? CalendarEventContentViewController)?.header else {
            return false
        }
        let convertedPoint = coordinateSpace.convert(point, to: header)
        return header.bounds.contains(convertedPoint)
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, willTranslateOverlay overlayViewController: UIViewController, transitionCoordinator: OverlayContainerTransitionCoordinator) {

        let percentOpen = percent(forTranslation: transitionCoordinator.overlayTranslationHeight, coordinator: transitionCoordinator)
        eventContentViewController?.configureViewWithOpenPercent(percent: min(1, max(0, percentOpen)))

        transitionCoordinator.animate(alongsideTransition: { (context) in
            let percentOpen = self.percent(
                forTranslation: context.targetTranslationHeight,
                coordinator: transitionCoordinator
            )
            self.configureWhiteFade(percent: percentOpen)
            self.eventContentViewController?.configureViewWithOpenPercent(percent: min(1, max(0, percentOpen)))
        }, completion: nil)
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, willMoveOverlay overlayViewController: UIViewController, toNotchAt index: Int) {
        let beforeNotchIndex = self.notchIndex
        self.notchIndex = index
        if beforeNotchIndex != 0 && notchIndex == 0 {
            animateDismiss()
        }
    }
}

extension CalendarEventViewController: CalendarEventContentDelegate {
    func closePopup() {
        presenter?.closePopupPressed()
    }
    
    func openUrlInWebContent(url: String) {
        presenter?.openUrlInWebContent(url: url)
    }
}

extension CalendarEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let eventContentVC = eventContentViewController, let eventContentView = eventContentVC.view {
            if touch.view!.isDescendant(of: eventContentView) {
                return false
            }
        }
        return true
    }
}
