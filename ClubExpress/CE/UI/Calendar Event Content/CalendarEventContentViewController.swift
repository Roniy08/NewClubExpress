//
//  CalendarEventContentViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import WebKit

protocol CalendarEventContentDelegate: class {
    func closePopup()
    func openUrlInWebContent(url: String)
}

class CalendarEventContentViewController: UIViewController {

    var organisationColours: OrganisationColours!
    var event: CalendarEvent? {
        didSet {
            presenter?.event = event
        }
    }
    var presenter: CalendarEventContentPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    weak var delegate: CalendarEventContentDelegate?
    fileprivate var overlayPercent: CGFloat = 0
    fileprivate var webView: AutoResizeWebView?
    fileprivate var ads = Array<NativeAd>()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dragIndicator: UIView!
    @IBOutlet weak var calendarNameLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var detailLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var upcomingEventsTitleLabel: UILabel!
    @IBOutlet weak var upcomingEventsLabel: UILabel!
    @IBOutlet weak var descriptionWebViewWrapper: UIView!
    @IBOutlet weak var upcomingEventsWrapper: UIView!
    @IBOutlet weak var webViewStackItem: UIView!
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var bottomAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addWebView()
        
        setupView()
        
        presenter?.viewDidLoad()
    }
    
    fileprivate func setupView() {
        headerTitleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 20)
        headerTitleLabel.textColor = organisationColours.textColour
        headerTitleLabel.numberOfLines = 1
        headerTitleLabel.lineBreakMode = .byTruncatingTail
        
        dragIndicator.layer.cornerRadius = 1.5
        dragIndicator.clipsToBounds = true
        
        calendarNameLabel.font = UIFont.openSansBoldFontOfSize(size: 15)
        
        startLabel.font = UIFont.openSansFontOfSize(size: 15)
        startLabel.textColor = UIColor.mtMatteBlack
       
        endLabel.font = UIFont.openSansFontOfSize(size: 15)
        endLabel.textColor = UIColor.mtMatteBlack
        
        upcomingEventsTitleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        upcomingEventsTitleLabel.textColor = UIColor.mtMatteBlack
        
        upcomingEventsLabel.font = UIFont.openSansFontOfSize(size: 15)
        upcomingEventsLabel.textColor = UIColor.mtMatteBlack
    }
   
    @IBAction func closeBtnPressed(_ sender: Any) {
        presenter?.closeBtnPressed()
    }
    
    func configureViewWithOpenPercent(percent: CGFloat) {
        self.overlayPercent = percent
        
        updateViewCornerRadius()
        updateHeaderHeight()
        updateHeaderTitle()
        updateCloseBtn()
    }
    
    fileprivate func updateViewCornerRadius() {
        let biggestCornerRadius:CGFloat = 15
        let lowestCornerRadius: CGFloat = 8
        let flippedPercent = 1 - self.overlayPercent
        
        let percentCornerRadius = (flippedPercent * (biggestCornerRadius - lowestCornerRadius)) + lowestCornerRadius
        var rect = view.bounds
        if #available(iOS 11.0, *) {
            let safeAreaInsets = view.safeAreaInsets
            rect.size.width -= (safeAreaInsets.left + safeAreaInsets.right)
        }
        
        view.roundCorners(corners: [.topLeft, .topRight], radius: percentCornerRadius, rect: rect)
    }
    
    fileprivate func updateHeaderHeight() {
        let biggestHeight:CGFloat = 80
        let lowestHeight: CGFloat = 60
        let flippedPercent = 1 - self.overlayPercent
        
        let percentHeaderHeight = (flippedPercent * (biggestHeight - lowestHeight)) + lowestHeight
        headerHeightConstraint.constant = percentHeaderHeight
    }
    
    fileprivate func updateHeaderTitle() {
        let biggestFontSize:CGFloat = 20
        let smallestFontSize: CGFloat = 18
        let flippedPercent = 1 - self.overlayPercent
        
        let percentFontSize = (flippedPercent * (biggestFontSize - smallestFontSize)) + smallestFontSize
        headerTitleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: percentFontSize)
    }
    
    fileprivate func addWebView() {
        //Add webview programtically instead of storyboard for iOS 10 fix
        webView = AutoResizeWebView(frame: descriptionWebViewWrapper.bounds)
        webView!.backgroundColor = UIColor.white
        webView!.translatesAutoresizingMaskIntoConstraints = false
        webView!.scrollView.isScrollEnabled = false
        webView!.scrollView.delegate = self
        webView!.delegate = self
        descriptionWebViewWrapper.addSubview(webView!)
        webView!.constraintToSuperView(superView: descriptionWebViewWrapper)
    }
    
    fileprivate func updateCloseBtn() {
        closeBtn.alpha = self.overlayPercent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.updateViewCornerRadius()
            self.webView!.updateIntrinsicContentSize()
        }, completion: nil)
    }
}

extension CalendarEventContentViewController: CalendarEventContentView {
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
    
    func setTitle(title: String) {
        headerTitleLabel.text = title
    }
    
    func closePopupEvent() {
        delegate?.closePopup()
    }
    
    func configureView(event: CalendarEvent) {
        if let calendar = event.parentCalendar, let colourCode = calendar.colourCode {
            let colour = UIColor(hex: colourCode)
            header.backgroundColor = colour
            calendarNameLabel.textColor = colour
            
            let textColour = colour.isDarkColour() ? UIColor.white : UIColor.mtMatteBlack
            headerTitleLabel.textColor = textColour
            closeBtn.tintColor = textColour
            dragIndicator.backgroundColor = textColour
        }
    }
    
    func setCalendarName(name: String) {
        calendarNameLabel.text = name
    }
    
    func setStartDate(dateString: NSAttributedString) {
        startLabel.attributedText = dateString
    }
    
    func setEndDate(dateString: NSAttributedString) {
        endLabel.attributedText = dateString
    }
    
    func toggleLoadingIndicator(show: Bool) {
        switch show {
        case true:
            detailLoadingIndicator.startAnimating()
        case false:
            detailLoadingIndicator.stopAnimating()
        }
    }
    
    func showEventDetailErrorPopup() {
        showAlertPopup(title: "Event Detail Error", message: "There was an error loading the event detail.")
    }
    
    func setEventDescriptionWebView(html: String) {
        let htmlStart = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no\"></head>"
        let bodyStart = "<body>"
        let fontName = "Open Sans"
        let fontSource = "OpenSans-Regular.ttf"
        let fontColour = "#23272D"
        let css = "<style>html { -webkit-text-size-adjust: none; } body { color: \(fontColour); margin: 0; padding: 0; font-family: '\(fontName)'; font-size:15; } @font-face { font-family: '\(fontName)'; font-weight: normal; src: url('\(fontSource)'); } img { max-width: 100%!important; height: auto; }</style>"
        let bodyEnd = "</body>"
        let htmlEnd = "</html>"
        
        let htmlString = "\(htmlStart)\(bodyStart)\(html)\(css)\(bodyEnd)\(htmlEnd)"
        
        let bundleUrl = Bundle.main.bundleURL
        webView?.loadHTMLString(htmlString, baseURL: bundleUrl)
    }
    
    func setUpcomingDatesLabel(text: String) {
        upcomingEventsLabel.text = text
    }
    
    func setUpcomingDatesHeader(title: String) {
        upcomingEventsTitleLabel.text = title
    }
    
    func hideUpcomingDatesWrapper() {
        upcomingEventsWrapper.isHidden = true
    }
    
    func hideWebViewStackItem() {
        webViewStackItem.isHidden = true
    }
    
    func toggleEventDescriptionWebView(show: Bool) {
        switch show {
        case true:
            webView?.alpha = 1
        case false:
            webView?.alpha = 0
        }
    }
    
    func openUrlInWebContent(url: String) {
        delegate?.openUrlInWebContent(url: url)
    }
}

extension CalendarEventContentViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension CalendarEventContentViewController: AutoResizeWebViewDelegate {
    func webViewDidFinishLoadingHeight(webView: WKWebView) {
        presenter?.webViewDidFinishLoadingHeight()
    }
    
    func webViewLinkClicked(webView: WKWebView, url: String) {
        presenter?.webViewLinkClicked(url: url)
    }
}
