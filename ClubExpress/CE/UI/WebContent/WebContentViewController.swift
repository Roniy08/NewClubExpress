//
//  WebContentViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import WebKit
import CoreBluetooth
import CoreLocation
import DeviceKit
import CoreNFC
import Photos
import EventKit


class WebContentViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate{
    var organisationColours: OrganisationColours!
    var presenter: WebContentPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    @IBOutlet weak var toolbar: UIToolbar!
    var webContentEntry: WebContentItem?
    fileprivate var webView: WKWebView?
    fileprivate var ads = Array<NativeAd>()
    weak var delegate: WebContentDelegate?
    fileprivate var loadingBarButtonItem: UIBarButtonItem?
    fileprivate var basketBarButtonItem: UIBarButtonItem?
    fileprivate var dismissBarButtonItem: UIBarButtonItem?

    var backButton: UIBarButtonItem?
    var docLoader: UIAlertController?
    var forwardButton: UIBarButtonItem?
    var WebContentpresenter: WebContentPresenter?
    let locationManager = CLLocationManager()
    var statusLocation :Bool = false
    var locationallowed :Bool = true
    var progressAlertController: UIAlertController!
    var progressView = UIProgressView()
    var currentLocation: CLLocation!
    var latitudeStore :Double = 0.0
    var longitudeStore :Double = 0.0

   
    //stripe variables
//    var isBluetooth : Bool = false
//    var sdkErrorCode: Int?
    var connectionConfigsLcoation = MembershipAPIRouter.stripe_Location_Id ?? ""
    var stripeM2Peripheral: CBPeripheral!
    let batteryLevelCharacteristicUUID = CBUUID(string: "180F")
//    var discoverCancelable: Cancelable?
//    var collectCancelable: Cancelable?
    var isPayment : Bool = false
    var paymentResponseData : [AnyHashable: Any] = [:]
    var readerDisconnectStatus : Bool = false
    var readerDisconnectUnexpectedlyStatus : Bool = false
    var failedConnectReaderInfo = ""
    var isConnectedReader : Bool = false
    var paymentIntentId = ""
    var isNFC : Bool = false
    var isNFCCompatible = ""
    var isDisconnectTapandPay : Bool = false
    var NFCStatus = ""
    
    var jsonStringToPass = String()
    var basketIconView: BasketIconView?
    var showDismissBtn = false
    var isBluetoothError = false
    var showCartBtn = true
    var paymentFailed: String = ""
    var readerDescription: String?
    var alertPaymentController: UIAlertController!
    var updateAlertController: UIAlertController!
//    var temppaymentIntent: PaymentIntent?
//    var cancelable: Cancelable?
    var constAlertString = "Please make sure\n 1. The reader is online/available\n 2. The reader is within the range\nThis alert will close as soon as the reader is discovered."
    var isUrlWhileLoggedOut = false {
        didSet {
            presenter?.isUrlWhileLoggedOut = isUrlWhileLoggedOut
        }
    }
    
    // reader variables
    var readerDataInfo : [String: Any] = [:]
    var isReaderInfo : Bool = false
    var isCancelPaymentError : Bool = false
    var isCancelPaymentErrorDesc: String?
    var isReaderDiscoverrconnected : Bool = false
    var elapsedTime: TimeInterval = 0.0
    let desiredInterval: TimeInterval = 20.0
    var batteryTimer: Timer?
    var elapsedTimer: Timer?
    var readerPowerTimer: Timer?
    var batteryCount: Int = 0
    var DeviceInfo :String = ""
   
    
    @IBOutlet weak var webViewWrapper: UIView!
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var bottomAdImageView: UIImageView!
    @IBOutlet weak var topAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAdHeightConstraint: NSLayoutConstraint!
    var topAd: NativeAd?
    var bottomAd: NativeAd?
    let eventStore = EKEventStore()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        addWebView()
        
        setupView()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        presenter?.webContentEntry = self.webContentEntry

        if locationallowed == false
        {
            locationManager.delegate = self
        }
        presenter?.viewDidLoad()
        
    }

    func permissionLocation()
    {
//         locationManager.delegate = self // Set delegate to handle location updates
//        locationManager.requestAlwaysAuthorization()
        
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                let status = CLLocationManager.authorizationStatus()
                switch status {
                case .authorizedAlways:
                    
//                    self.createJsonToPass(status: locationConstants.isY)
//                    self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                    self.locationManager.requestLocation()
                    if self.latitudeStore != 0.0 && self.longitudeStore != 0.0
                    {
                        self.locationManager.stopUpdatingLocation()
                    }
                    self.statusLocation = true
                    self.locationallowed = true
                    break
                    // Handle case
                case .authorizedWhenInUse:
//                    self.createJsonToPass(status: locationConstants.isY)
//                    self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                    self.locationManager.requestLocation()
                    self.statusLocation = true
                    self.locationallowed = true
                    if self.latitudeStore != 0.0 && self.longitudeStore != 0.0
                    {
                        self.locationManager.stopUpdatingLocation()
                    }
                    break
                    // Handle case
                case .denied:
                    print("permission denied")
                    self.showAlertPopup(title: "Alert", message: "Location is disabled for app, enable it from settings")
                    self.statusLocation = false
                    self.locationallowed = false
                    break
                    // Handle case
                case .notDetermined:
                    self.permissionLocation()
                    self.statusLocation = false
                    self.locationallowed = false
                    // Handle case
                    break
                case .restricted:
                    self.showAlertPopup(title: "Alert", message: "Location is Restricted for app change Location settings from settings")
                    self.statusLocation = false
                    self.locationallowed = false
                    break
                    // Handle case
                @unknown default:
                    break
                }
            }
            else
            {
                self.showAlertPopup(title: "Alert", message: "Location is off")
                print("location is off")
                self.statusLocation = false
                self.locationallowed = false
            }
        }
    }
    func permissionBluetooth()
    {
        var centralManager: CBCentralManager?
        if centralManager == nil {
           centralManager = CBCentralManager(delegate: self, queue: nil)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewIsVisible(visible: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewIsVisible(visible: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView?.endEditing(true)
    }
    func callAlertConnectReader()
    {
        alertPaymentController = UIAlertController(title: "Connecting to the reader...", message: constAlertString, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle any action if needed
            self.sendNoReaderStatus()
        }
        alertPaymentController.addAction(dismissAction)
               // Present the alert
        present(alertPaymentController, animated: true, completion: nil)
    }
    
    fileprivate func addWebView() {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
        //Add webview programtically instead of storyboard for iOS 10 fix
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "adHandler")
        contentController.add(self, name: "JSToApp") // https://lumaverse.atlassian.net/wiki/spaces/MTK/pages/279805956/App+-+JS+Communication#JS-%E2%86%92-App
        contentController.add(self, name: "MTKAppToJS") // https://lumaverse.atlassian.net/wiki/spaces/MTK/pages/279805956/App+-+JS+Communication#App-%E2%86%92-JS
        configuration.userContentController = contentController
        webView = WKWebView(frame: webViewWrapper.bounds, configuration: configuration)
        webView!.backgroundColor = UIColor.white
        webView!.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/114.0.5735.99 Mobile/15E148 Safari/604.1 ce-platform/ios"
        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        webView!.translatesAutoresizingMaskIntoConstraints = false
        webViewWrapper.addSubview(webView!)
        webView!.constraintToSuperView(superView: webViewWrapper)
//        setupWebButtons()
//        let storeApiUrl = MembershipAPIRouter.storeURL
//        if ((storeApiUrl?.contains("_pos/")) != nil) {
//            self.navigationController?.toolbar.barTintColor = organisationColours.ColourForToolbarBackground
//            self.navigationController?.setToolbarHidden(true, animated: true)
//            self.navigationController?.navigationBar.isHidden = true
//            MembershipAPIRouter.storeURL = nil
//            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//            self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
////            Terminal.shared.delegate = self
////            locationManager.delegate = self
////            permissionBluetooth()
//        }
//        else
//        {
            self.navigationController?.toolbar.barTintColor = organisationColours.primaryBgColour
            self.navigationController?.setToolbarHidden(true, animated: true)
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
//            let accessEdgeGesture = OrganisationWrapperViewController();
//            accessEdgeGesture.addScreenEdgeGesture()
//        }
       
        
    }
    // MARK: Reader observers
    func showConnectReader() {
//        if isBluetooth == true
//        {
//            print("bluetooth status is on")
//        }
//        else
//        {
//            self.showAlertPopup(title: "Alert", message: "Turn on Bluetooth from settings")
//        }
       
//        setUpInterface()
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on.")
//            isBluetooth = true
            showConnectReader()
            break
        case .poweredOff:
            print("Bluetooth is Off.")
//            isBluetooth = false
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            print("Bluetooth is unsupported.")
            break
        case .unknown:
            break
        default:
            break
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Stripe M2" {
            stripeM2Peripheral = peripheral
            stripeM2Peripheral.delegate = self
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == batteryLevelCharacteristicUUID {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == batteryLevelCharacteristicUUID {
            let batteryLevel = characteristic.value?.first
            print("Stripe M2 battery level: \(batteryLevel ?? 0)%")
        }
    }
    // MARK: Reader Delegates
    // Reference : https://stripe.com/docs/terminal/payments/connect-reader?terminal-sdk-platform=ios&reader-type=bluetooth#1.-handle-the-disconnect-immediately
//    func terminal(_ terminal: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
//        if isNFC == false
//        {
//            print("reader disconencted")
//            self.readerPowerTimer?.invalidate()
//            self.readerPowerTimer = nil
//            self.batteryTimer?.invalidate()
//            self.batteryTimer = nil
//            self.readerDisconnectStatus = true
//            self.readerDisconnectUnexpectedlyStatus = true
//            self.createJsonToPass(status:M2EventConstants.connectionLost)
//            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//        }
//        else
//        {
//            self.isDisconnectTapandPay = true
//            self.createJsonToPass(status:disconnectTapandPayConstants.disconnectTapandPayResponse)
//            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//        }
//    }
//    func terminal(_ terminal: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
//        switch status {
//            case .notConnected:
//                print("Connection status: Not Connected")
//            case .connecting:
//                print("Connection status: Connecting")
//            case .connected:
//                print("Connection status: Connected")
//            }
//    }
//    func terminal(_ terminal: Terminal, didStartReaderReconnect cancelable: Cancelable) {
////        showAlertPopup(title: "Reader Reconnecting", message: "searching for reader....")
//        print("reconnecting reader again")
//        self.showAlertPopup(title: "Error", message: "reconnecting reader again")
//          // 1. Notified at the start of a reconnection attempt
//          // Use cancelable to stop reconnection at any time
//      }
//    
//    // first come here after getting update information.
//    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
//        print(update.description)
//        if self.alertPaymentController as? UIAlertController != nil {
//            DispatchQueue.main.async {
//                self.alertPaymentController.dismiss(animated: true, completion: nil)
//            }
//        }
//        DispatchQueue.main.async {
////            self.showAlertPopup(title: "Software Update",message: "update is available and installing..")
//        }
//        Terminal.shared.installAvailableUpdate()
//    }
//    // Reference: didRequestReaderInput inputOptions
//    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
//        print("\(inputOptions)")
////        DispatchQueue.main.async {
////            self.alertPaymentController = UIAlertController(title: "Information", message: "Swipe or tap the card to continue the transaction. Click Cancel to abort the transaction.", preferredStyle: .alert)
////
////               // Add any alert actions as needed
////        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
////            // Handle any action if needed
//////            self.showPaymentAlert()
////            let taskCall = Task {
////                await self.callCancelPayment()
////            }
////            self.isPayment = true
////            self.createJsonToPass(status: paymentConstants.paymentCancelled)
////            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
////        }
////            self.alertPaymentController.addAction(dismissAction)
////               // Present the alert
////            self.present(self.alertPaymentController, animated: true, completion: nil)
////        }
//    }
//    func showPaymentAlert()
//    {
//        let alert = UIAlertController(title: "Information", message: "Are you sure you want to Cancel transaction", preferredStyle: .alert)
//        // Add any alert actions as needed
//        let yesAction = UIAlertAction(title: "Yes", style: .cancel) { _ in
//        // Handle any action if needed
//            //payment cancelled optional popup disable
//            let taskCall = Task {
//                await self.callCancelPayment()
//            }
//            self.isPayment = true
//            self.createJsonToPass(status: paymentConstants.paymentCancelled)
//            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//        }
//        let dismissAction = UIAlertAction(title: "No", style: .default) { _ in
//        }
//        alert.addAction(dismissAction)
//        alert.addAction(yesAction)
//        // Present the alert
//        present(alert, animated: true, completion: nil)
//    }
//    func callCancelPayment() async
//    {
//       await cancelPaymentIntent(intent: temppaymentIntent!)
//    }
//    func callCancelPaymentExpireCard() async
//    {
//       await cancelPaymentIntentExpireCard(intent: temppaymentIntent!)
//    }
//    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
//        print(displayMessage)
//    }
    
    // Reference : https://stripe.com/docs/terminal/payments/connect-reader?reader-type=bluetooth#discover-readers
    
  /*  @objc func discoverReadersAction() throws{
        
        if isNFC == false
        {
            let config = try BluetoothScanDiscoveryConfigurationBuilder().setTimeout(UInt(20.0)).build()
            self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { error in
                        if let error = error {
                            DispatchQueue.main.async {
                            self.alertPaymentController.dismiss(animated: true, completion: nil)
                            }
                            self.readerPowerTimer?.invalidate()
                            self.readerPowerTimer = nil
                            self.elapsedTimer?.invalidate()
                            self.elapsedTimer = nil
                            print("discoverReaders failed: \(error)")
                            if let error = error as? String {
                                self.showAlertPopup(title: "Error", message: "\(error.description)")
                            }
                            else
                            {
                                let fullErrorDesc = error as NSError
                                print(fullErrorDesc.localizedDescription)
                                self.sdkErrorCode = fullErrorDesc.code
                                print(self.sdkErrorCode)
                                let bluetoothError = fullErrorDesc.localizedDescription as String
                                if let presentedAlert = self.presentedViewController as? UIAlertController {
                                    presentedAlert.dismiss(animated: false, completion: {
                                        switch fullErrorDesc.code {
                                        case 2320:
                                            // Handle Bluetooth error 2320
                                            self.showAlertPopup(title: "Bluetooth Access", message: "Bluetooth is disabled on this iOS device. Enable Bluetooth in Settings > Bluetooth.")
                                            self.readerDescription = fullErrorDesc.localizedDescription ?? "Bluetooth is disabled on this iOS device. Enable Bluetooth in Settings > Bluetooth."
                                        case 2321:
                                            // Handle Bluetooth error 2321
                                            self.showAlertPopup(title: "Bluetooth Access", message: "Bluetooth access is required for card reader. Enable Bluetooth access for Membership app in Settings.")
                                            self.readerDescription = "Bluetooth access is required for card reader. Enable Bluetooth access for Membership app in Settings."
                                        default:
                                            // Handle other cases
                                            self.readerDescription = fullErrorDesc.localizedDescription ?? ""
    //                                        self.showAlertPopup(title: "Error", message: bluetoothError)

                                        }
                                        
                                        self.isBluetoothError = true
                                        self.createJsonToPass(status: readerConstants.bluetoothError)
                                        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                                    })
                                }
                                self.readerPowerTimer?.invalidate()
                                self.readerPowerTimer = nil
                                self.elapsedTimer?.invalidate()
                                self.elapsedTimer = nil
                            }
                           
                        } else {
                            self.readerPowerTimer?.invalidate()
                            self.readerPowerTimer = nil
    //                        print("discoverReaders succeeded")
                        }
                   }
        }
        else
        {
//            let config = DiscoveryConfiguration(
//                       discoveryMethod: .localMobile,
//                       locationId: nil,
//                     simulated: false
//                   )
            let config = try LocalMobileDiscoveryConfigurationBuilder().setSimulated(false).build()
            self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { error in
                if let error = error {
                    print("discoverReaders failed: \(error)")
                    let taskCall = Task {
                        await self.cancelDiscoverAction()
                    }
                } else {
                    print("discover NFC Reader succeeded")
                }
            }
        }

    }
    func terminal(_ terminal: Terminal, didFailToConnectReaderWithError error: Error) {
       // Handle the case where the reader is not turned on or not available
       self.showAlertPopup(title: "Information", message: error.localizedDescription)
        self.readerDescription = error.localizedDescription
       print("Failed to connect reader: \(error.localizedDescription)")
        isConnectedReader = true
        let fullErrorDesc = error as NSError
        print(fullErrorDesc.code)
        self.sdkErrorCode = fullErrorDesc.code
        self.createJsonToPass(status: readerConstants.statusFailed)
        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
    }
    // MARK: checkout
    // Reference: https://stripe.com/docs/terminal/payments/collect-payment?terminal-sdk-platform=ios#process-payment
    func checkoutButtonAction() {
        Terminal.shared.retrievePaymentIntent(clientSecret: MembershipAPIRouter.stripe_Client_Secret!) { retrieveResult, retrieveError in
            if let error = retrieveError {
                print("retrievePaymentIntent failed: \(error)")
                self.isPayment = true
//                self.createJsonToPass(status:paymentConstants.statuFailed)
//                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//                self.showAlertPopup(title: "Information", message: error.localizedDescription)
                print(error.localizedDescription)
                let fullErrorDesc = error as NSError
                print(fullErrorDesc.code)
                self.sdkErrorCode = fullErrorDesc.code
                self.createJsonToPass(status: paymentConstants.statuserror)
                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            }
            else if let paymentIntent = retrieveResult {
                print("retrievePaymentIntent succeeded: \(paymentIntent.originalJSON)")
                self.temppaymentIntent = paymentIntent
                self.collectCancelable = Terminal.shared.collectPaymentMethod(paymentIntent) { collectResult, collectError in
                    print(collectResult?.metadata ?? "")
                    print(collectError?.localizedDescription ?? "")
                    if let error = collectError {
                        let fullErrorDesc = error as NSError
                        print(fullErrorDesc.code)
                        print(fullErrorDesc.localizedDescription)
                        print("collectPaymentMethod failed: \(error)")
                        if self.isNFC == true
                        {
                            self.isPayment = true
                            self.createJsonToPass(status: paymentConstants.paymentCancelled)
                            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                            do {
                                try self.discoverReadersAction()
                                } catch {
                                    print("Error: \(error)")
                                }
                        }
                    } else if let collectPaymentMethodPaymentIntent = collectResult {
                        print(collectResult)
                        print("collectPaymentMethod succeeded")
                        // ... Process the payment
                        Terminal.shared.confirmPaymentIntent(collectPaymentMethodPaymentIntent) { processResult, processError in
                            if let error = processError {
                                let fullErrorDesc = error as NSError
                                print(fullErrorDesc.code)
                                self.sdkErrorCode = fullErrorDesc.code
                                print("processPayment failed: \(error.localizedDescription)")
                                
//                                self.showAlertPopup(title: "Expired card processPayment failed:", message:  error.declineCode ?? "")
                                if let presentedAlert = self.presentedViewController as? UIAlertController {
                                    presentedAlert.dismiss(animated: false, completion: {
                                        // Present the new alert controller after the existing one is dismissed
//                                        self.showAlertPopup(title: "processPayment failed", message: error.localizedDescription)
                                    })
                                }
                               
                                self.isPayment = true
                                self.paymentFailed = fullErrorDesc.localizedDescription
                                print(self.paymentFailed)
                                if let errorCode = self.sdkErrorCode {
                                    // Variable has a value: errorCode
                                    let taskCall = Task {
                                        await self.callCancelPaymentExpireCard()
                                    }
                                } else {
                                    print("sdkErrorCode is nil")
                                }
                                self.createJsonToPass(status: paymentConstants.statuserror)
                                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                                
                            } else if let processPaymentPaymentIntent = processResult {
                                let tempDict = processResult?.originalJSON
                                print(tempDict)
                                print("processPayment succeeded")
//                                DispatchQueue.main.async {
//                                self.alertPaymentController.dismiss(animated: true, completion: nil)
//                                }
                                self.isPayment = true
                                self.paymentResponseData = tempDict!
                                self.createJsonToPass(status: paymentConstants.statusSuccess)
                                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                                // Notify your backend to capture the PaymentIntent
                            }
                        }
                    }
                }
            }
        }
    }
    func cancelDiscoverAction() async {
        do {
            try await self.discoverCancelable?.cancel()
            }
          catch {
               // Handle the error here (if needed)
               print("Error canceling discover: \(error)")
           }
        }
    func cancelPaymentIntent(intent: PaymentIntent) async {
        do {
            try await self.collectCancelable?.cancel()
            // Cancellation was successful
               print("Cancellation successful")
             self.callApiCancelPayment()
              
          }    // Optionally, perform any additional cleanup or handling when canceled
          catch {
               // Handle the error here (if needed)
              print("Error canceling payment: \(error.localizedDescription)")
              self.isCancelPaymentError = true
              let fullErrorDesc = error as NSError
              self.sdkErrorCode = fullErrorDesc.code
              self.paymentFailed = fullErrorDesc.localizedDescription
              //................. here expire card makes issue that are from stripe sdk need to change here.............//
              self.cancelPaymentError()
              let taskCall = Task {
                  await self.callCancelPaymentExpireCard()
              }
           }
        }
    func cancelPaymentIntentExpireCard(intent: PaymentIntent) async {
        do {
            try await self.collectCancelable?.cancel()
            // Cancellation was successful
               print("Cancellation successful")
              
          }    // Optionally, perform any additional cleanup or handling when canceled
          catch {
               // Handle the error here (if needed)
              print("Error canceling payment: \(error.localizedDescription)")
           }
        }
    func cancelPaymentError()
    {
        self.createJsonToPass(status: paymentConstants.statuserror)
        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
    }
    func callApiCancelPayment()
    {
            self.createJsonToPass(status: paymentConstants.cancelPaymentResponse)
            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
        
    }
    // MARK: Bluetooth DiscoveryDelegate
    //Reference: https://stripe.com/docs/terminal/payments/connect-reader?reader-type=bluetooth#connect-reader
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        if readers.isEmpty {
           print("No readers found.")
//            self.sendNoReaderStatus()
           return
        }
        else
        {
            self.readerPowerTimer?.invalidate()
            self.readerPowerTimer = nil
            
//            DispatchQueue.main.async {
//                self.alertPaymentController.dismiss(animated: true, completion: nil)
//            }
            print("\(readers.count) readers found")
        }
        // Select the first reader the SDK discovers. In your app,
        // you should display the available readers to your user, then
        // connect to the reader they've selected.
        guard let selectedReader = readers.first else { return }

        // Only connect if we aren't currently connected.
        guard terminal.connectionStatus == .notConnected else { return }

        if self.isNFC == true
        {
            if readers.isEmpty {
               print("No readers found.")
               return
            }
            guard let selectedReader = readers.first else { return }
            let connectionConfigLocal: LocalMobileConnectionConfiguration
            do {
                connectionConfigLocal = try LocalMobileConnectionConfigurationBuilder(locationId: connectionConfigsLcoation).build()
            } catch {
                // Handle the error building the connection configuration
                return
            }
            Terminal.shared.connectLocalMobileReader(selectedReader, delegate: self, connectionConfig: connectionConfigLocal) { reader, error in
                if let reader = reader {
                       print("Successfully connected to NFC reader: \(reader)")
                    self.NFCStatus = "success"
                    self.createJsonToPass(status: ConnectNFCConstants.ConnectNFCResponse)
                    self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                   } else if let error = error {
                       let fullErrorDesc = error as NSError
                       print(fullErrorDesc.code)
                       self.sdkErrorCode = fullErrorDesc.code
                       self.readerDescription = fullErrorDesc.localizedDescription 
                       self.NFCStatus = "error"
                       print("connectLocalMobileReader failed: \(error)")
                       let taskCall = Task {
                           await self.cancelDiscoverAction()
                       }
                       self.createJsonToPass(status: ConnectNFCConstants.ConnectNFCResponse)
                       self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                       
                   }
                }
        }
        else
        {
            if readers.isEmpty {
               print("No readers found.")
               return
            }
            else
            {
                self.readerPowerTimer?.invalidate()
                self.readerPowerTimer = nil
                print("\(readers.count) readers found")
            }
            // Select the first reader the SDK discovers. In your app,
            // you should display the available readers to your user, then
            // connect to the reader they've selected.
            guard let selectedReader = readers.first else { return }

            // Only connect if we aren't currently connected.
            guard terminal.connectionStatus == .notConnected else { return }
            let connectionConfig: BluetoothConnectionConfiguration
            do {
                connectionConfig = try BluetoothConnectionConfigurationBuilder(locationId: connectionConfigsLcoation).build()
            } catch {
                // Handle the error building the connection configuration
                return
            }
            Terminal.shared.connectBluetoothReader(selectedReader, delegate: self, connectionConfig: connectionConfig) { reader, error in
                    if let reader = reader {
                        print("Successfully connected to reader: \(reader)")
                        self.readerPowerTimer?.invalidate()
                        self.readerPowerTimer = nil
                        self.elapsedTimer?.invalidate()
                        self.elapsedTimer = nil
                        DispatchQueue.main.async {
                            self.alertPaymentController.dismiss(animated: true, completion: nil)
                        }
                        let batteryLevelReader: Double = reader.batteryLevel as! Double
                        let convertedValue = Int(batteryLevelReader * 100.0)
                        let batteryDecimalStatus = min(max(convertedValue, 0), 100)
                        let readerHardwareinfo = reader.value(forKey: "hardwareInfo") as! Any
                        do {
                            let readerDict: [String: Any] = [
                                "deviceSoftwareVersion": reader.deviceSoftwareVersion,
                                "serialNumber": reader.serialNumber,
                                "stripeId": reader.stripeId,
                                "hardwareInfo": readerHardwareinfo
                            ]
                             self.readerDataInfo = readerDict
                        } catch {
                            print("Error converting to JSON: \(error)")
                        }
                        if let reader = Terminal.shared.connectedReader, reader.deviceType == .stripeM2 {
                            let batteryLevelReader = reader.batteryLevel as! Double
                            let convertedValue = Int(batteryLevelReader * 100.0)
                            let percentageBattery = min(max(convertedValue, 0), 100)
                            if percentageBattery > 20
                            {
                                // Start the timer to retrieve battery status every 5 minute
                                self.batteryTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.getBatteryStatusRegular), userInfo: nil, repeats: true)
                            }
                            else
                            {
                                // Start the timer to retrieve battery status every 60 seconds
                                self.batteryTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.getBatteryStatus), userInfo: nil, repeats: true)
                            }
                         
                        }
                        if self.isReaderDiscoverrconnected == true
                        {
                            Terminal.shared.disconnectReader { error in
                                if let error = error {
                                    print("Disconnect failed: \(error)")
                                    self.showAlertPopup(title: "Disconnect Error", message:"\(error)")
                                    self.isReaderDiscoverrconnected = false
                                } else {
                                    print("disconnected successfully")
                                    self.batteryTimer?.invalidate()
                                    self.batteryTimer = nil
                                    self.isReaderDiscoverrconnected = false
                                }
                            }
                        }
                        else
                        {
                            self.isConnectedReader = true
                            self.createJsonToPass(status: readerConstants.statusSuccess)
                            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                        }
                     
                    } else if let error = error {
                        print("connectReader failed: \(error)")
        //                self.readerPowerTimer?.invalidate()
        //                self.readerPowerTimer = nil
                        let fullErrorDesc = error as NSError
                        print(fullErrorDesc.code)
                        self.sdkErrorCode = fullErrorDesc.code
                        self.readerDescription = fullErrorDesc.localizedDescription ?? ""
                        self.isConnectedReader = true
                        self.showAlertPopup(title: "Error", message: "\(error.localizedDescription)")
                        self.failedConnectReaderInfo = error.localizedDescription
                        self.createJsonToPass(status: readerConstants.statusFailed)
                        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")

                    }
                }
        }

   
    }
    
    // MARK: reader on or off Status
    @objc func getReaderPowerStatus() {
        isConnectedReader = true
        self.createJsonToPass(status:readerConstants.statusFailed)
        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
    }
    // MARK: reader Battery Info <= 20%
    @objc func getBatteryStatus() {
        if let reader = Terminal.shared.connectedReader, reader.deviceType == .stripeM2 {
            let batteryLevelReader = reader.batteryLevel as! Double
            let convertedValue = Int(batteryLevelReader * 100.0)
            let percentageValue = min(max(convertedValue, 0), 100)
            print(percentageValue)
            self.batteryCount = percentageValue
            if self.batteryCount > 0
                        {
                            isReaderInfo = true
                            self.createJsonToPass(status:M2StateConstants.statusSuccess)
                            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                        }
                    }
                }
    // MARK: reader Battery Info interval 5 minute
    @objc func getBatteryStatusRegular() {
        if let reader = Terminal.shared.connectedReader, reader.deviceType == .stripeM2 {
            let batteryLevelReader = reader.batteryLevel as! Double
            let convertedValue = Int(batteryLevelReader * 100.0)
            let percentageValue = min(max(convertedValue, 0), 100)
            print(percentageValue)
            self.batteryCount = percentageValue
            
            if self.batteryCount > 0 && self.batteryCount <= 20
            {
                isReaderInfo = true
                batteryTimer?.invalidate()
                batteryTimer = nil
                self.batteryTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.getBatteryStatus), userInfo: nil, repeats: true)
                self.createJsonToPass(status:M2StateConstants.statusSuccess)
                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            }
            else
            {
                isReaderInfo = true
                self.createJsonToPass(status:M2StateConstants.statusSuccess)
                self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            }
        }
    }
    // MARK: Bluetooth Reader
    func disconnectFromReader() {
        if  self.isConnectedReader == true
        {
            Terminal.shared.disconnectReader { error in
                if let error = error {
                    print("Disconnect failed: \(error)")
                    self.showAlertPopup(title: "Disconnect Error", message:"\(error)")
                    self.readerDisconnectStatus = true
                    self.createJsonToPass(status:readerConstants.statusFailed)
                    self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                } else {
                    self.readerDisconnectStatus = true
                    self.createJsonToPass(status:readerConstantsDisconnect.statusSuccess)
                    self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
                    print("disconnected successfully")
                    self.batteryTimer?.invalidate()
                    self.batteryTimer = nil
                }
            }
        }
    }
    // second time comes here for install start
    @objc func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        if self.alertPaymentController as? UIAlertController != nil {
            DispatchQueue.main.async {
                self.alertPaymentController.dismiss(animated: true, completion: nil)
            }
        }
//        DispatchQueue.main.async {
//            self.updateAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//
//                // Create an attributed string for the title with custom font and size
//                let titleAttributedString = NSMutableAttributedString(string: "Reader updating\nPlease wait...\n", attributes: [
//                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
//                    NSAttributedString.Key.foregroundColor: UIColor.black
//                ])
//
//                // Append the original title with custom attributes
//                let originalTitle = NSAttributedString(string: "This may take up to few minutes\n", attributes: [
//                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
//                    NSAttributedString.Key.foregroundColor: UIColor.black
//                ])
//
//                titleAttributedString.append(originalTitle)
//            self.updateAlertController.setValue(titleAttributedString, forKey: "attributedTitle")
//            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 110, y:75, width: 40, height: 40))
//            loadingIndicator.hidesWhenStopped = true
//            loadingIndicator.style = UIActivityIndicatorView.Style.gray
//            loadingIndicator.startAnimating()
//            self.updateAlertController.view.addSubview(loadingIndicator)
//            let height: CGFloat = 240
//            self.updateAlertController.preferredContentSize = CGSize(width: 250, height: height)
//            // Present the alert
//            self.present(self.updateAlertController, animated: true, completion: nil)
//        }
        DispatchQueue.main.async {
                  self.updateAlertController = UIAlertController(title: "Reader updating \n Please wait...\n", message: nil, preferredStyle: .alert)

                  let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 238, height: 60))
                     containerView.layer.cornerRadius = 5
                     // Create and add the progress bar to the container view
                  self.progressView = UIProgressView(progressViewStyle: .default)
                  self.progressView.frame = CGRect(x: 20, y: 80, width: containerView.frame.width - 30, height: 10)
                  self.progressView.tintColor = UIColor.blue
                  containerView.addSubview(self.progressView)

                     // Center the progress bar horizontally
                  let newXPosition = containerView.frame.width  - (self.progressView.frame.width / 2)
                  self.progressView.center.x = newXPosition

                     // Set up the container view with progress bar
                  self.updateAlertController.view.addSubview(containerView)

                  // Present the alert
                  self.present(self.updateAlertController, animated: true, completion: nil)
              }
        // Show UI communicating that a required update has started installing
        print("update")
    }*/

  /*  @objc func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float)
    {
        print("\(progress)% completed")
        var currentProgress: Float = progress
        let targetProgress: Float = 1.0
        self.progressView.progress = currentProgress
     print(currentProgress)
        // Update the progress of the install
    }

    @objc func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
        print("update success")
        DispatchQueue.main.async {
            // Update the progress view here
            self.updateAlertController.dismiss(animated: true, completion: nil)
//            self.progressView.progress = 0.0
        }
//        showAlertPopup(title: "Information", message: "Reader is updated successfully")
        // Report success or failure of the update
    }
    
    func terminalDidSucceedReaderReconnect(_ terminal: Terminal) {
        print("reconnect successfully")
        self.isConnectedReader = true
        self.createJsonToPass(status:readerConstants.statusSuccess)
        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            // 2. Notified when reader reconnection succeeds
            // App is now connected
        }
        func terminalDidFailReaderReconnect(_ terminal: Terminal) {
            print("falied to reconnect reader",terminal.description)
            self.isConnectedReader = true
            self.createJsonToPass(status:readerConstants.statuserror)
            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            // 3. Notified when reader reconnection fails
            // App is now disconnected
        }
    // MARK: Local Mobile Reader Delegate
    // functions used for NFC via reader connection
    func localMobileReader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        if self.alertPaymentController as? UIAlertController != nil {
            DispatchQueue.main.async {
                self.alertPaymentController.dismiss(animated: true, completion: nil)
            }
        }
        DispatchQueue.main.async {
            self.updateAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

                // Create an attributed string for the title with custom font and size
                let titleAttributedString = NSMutableAttributedString(string: "Reader updating\nPlease wait...\n", attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ])

                // Append the original title with custom attributes
                let originalTitle = NSAttributedString(string: "This may take up to few minutes\n", attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ])

                titleAttributedString.append(originalTitle)
            self.updateAlertController.setValue(titleAttributedString, forKey: "attributedTitle")
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 110, y:75, width: 40, height: 40))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            self.updateAlertController.view.addSubview(loadingIndicator)
            let height: CGFloat = 240
            self.updateAlertController.preferredContentSize = CGSize(width: 250, height: height)
            // Present the alert
            self.present(self.updateAlertController, animated: true, completion: nil)
        }
    }*/
    
//    func localMobileReader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
//        //.....................replace code after complete progress in update.................
//        print("\(progress)% completed")
//        var currentProgress: Float = 0.0
//        let targetProgress: Float = 1.0
//        let progressIncrement: Float = progress
//        if currentProgress != progressIncrement
//        {
//        // Calculate the new progress value
//        currentProgress += progressIncrement
//        self.progressView.progress = currentProgress
//            print(currentProgress)
////            showAlertPopup(title: "percentage", message: String(currentProgress))
//        }
//        if currentProgress >= targetProgress {
//            // Do any completion tasks here
//        }
//    }
    
//    func localMobileReader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
//        print("update success")
//        DispatchQueue.main.async {
//            // Update the progress view here
//            self.updateAlertController.dismiss(animated: true, completion: nil)
////            self.progressView.progress = 0.0
//        }
//    }
//    
//    func localMobileReader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
//        print("\(inputOptions)")
//    }
    
//    func localMobileReader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
//        print(displayMessage)
//    }
    
    // MARK: webview tabbar
    func setupWebButtons(){
        let backButton = UIBarButtonItem(
                image: UIImage(named: "icArrowLeft"),
                style: .plain,
                target: self.webView,
                action: #selector(WKWebView.goBack))
        if(webView!.canGoBack){
            backButton.tintColor = organisationColours.tintColour
            backButton.isEnabled = true
        }
        else{
            backButton.isEnabled = false
            backButton.tintColor = UIColor.withAlphaComponent(organisationColours.tintColour)(0.5)
        }
    
       
        let forwardButton = UIBarButtonItem(
            image: UIImage(named: "icArrowRight"),
                style: .plain,
                target: self.webView,
                action: #selector(WKWebView.goForward))
        if(webView!.canGoForward){
            forwardButton.isEnabled = true
            forwardButton.tintColor = organisationColours.tintColour
        }
        else{
            forwardButton.isEnabled = false
            forwardButton.tintColor = UIColor.withAlphaComponent(organisationColours.tintColour)(0.5)
        }
        
        let shareButton = UIBarButtonItem(
            image: UIImage(named: "icShare"),
                style: .plain,
                target: self,
                action: #selector(displayShareSheet))
        shareButton.tintColor = organisationColours.tintColour


         let reloadButton = UIBarButtonItem(
                image: UIImage(named: "icRefresh"),
                style: .plain,
                target: self.webView,
            action: #selector(WKWebView.reload))
        reloadButton.tintColor = organisationColours.tintColour

        
        self.toolbarItems = [spacerPadding(), backButton, spacer(), forwardButton,  spacer(), shareButton ,  spacer(), reloadButton,spacerPadding()]
    
        self.backButton = backButton
        self.forwardButton = forwardButton
    }

    func spacerPadding() -> UIBarButtonItem {
        let negativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSeperator.width = 12
        return negativeSeperator
    }
    func spacer() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    @objc func displayShareSheet(){
        let items = [URL(string: (webContentEntry?.url)!)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func showAds(ad: NativeAd){
        if(ad.position != "" && ad.position != nil){
            if(ad.position!.contains("top")){
                let url = ad.imgSrc
                topAd = ad
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
                    bottomAd = ad
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
        }
    }
    
    @objc func topAdTapped(sender:UITapGestureRecognizer) {
        if(topAd != nil){
            if let url = URL(string: topAd!.href ?? "") {
                UIApplication.shared.open(url)
            }
        }
       
    }
        
        
    @objc func bottomAdTapped(sender:UITapGestureRecognizer) {
        if(bottomAd != nil){
            if let url = URL(string: bottomAd!.href ?? "") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.canGoBack) {
                self.backButton?.isEnabled = self.webView!.canGoBack
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                self.forwardButton?.isEnabled = self.webView!.canGoForward
            }
        }
    }
    
    fileprivate func setupView() {
        if showDismissBtn {
            let closeImage = UIImage(named: "icClosePopover")
            self.dismissBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismissBtnPressed))
            setupNavigationItems()
        }
    }
    
    @objc func dismissBtnPressed(barButton: UIBarButtonItem) {
        presenter?.dismissBtnPressed()
    }
    
    fileprivate func setupNavigationItems() {
        var navigationItems = [UIBarButtonItem]()
        
//        if let dismissBarButtonItem = self.dismissBarButtonItem {
//            navigationItems.append(dismissBarButtonItem)
//        }
//        
//        if let basketBarButtonItem = self.basketBarButtonItem {
//            navigationItems.append(basketBarButtonItem)
//        }
        
        if let loadingBarButtonItem = self.loadingBarButtonItem {
            navigationItems.append(loadingBarButtonItem)
        }
        
        self.navigationItem.rightBarButtonItems = navigationItems
    }
    
    
}
// MARK: webview Contentview & webview controller
extension WebContentViewController: WebContentView {
    func loadUrl(urlString: String) {
        print(urlString)
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
    }
    func loadULoginScreen(urlString: String) {
        print(urlString)
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
    }
    
    func loadHtmlContent(content: String) {
        webView?.loadHTMLString(content, baseURL: nil)
    }
    func loadLoginScreen(urlString: String) {
        presenter?.clearUserDefaults()
        self.sessionExpiredToLoginVC()
    }
    
   func setLoginNav()
    {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
    }
    func setTitle(title: String) {
        self.title = title
    }
    
    func toggleLoadingIndicator(show: Bool) {
        switch show {
        case true:
            let loadingIndicator = UIActivityIndicatorView()
            loadingIndicator.startAnimating()
            loadingIndicator.style = .white
            loadingIndicator.color = organisationColours.tintColour
            loadingBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        case false:
            loadingBarButtonItem = nil
        }
        setupNavigationItems()
    }
    // Function to add an event to the calendar
    
    func requestAccessToCalendar(completion: @escaping (Bool, Error?) -> Void) {
          let eventStore = EKEventStore()
          eventStore.requestAccess(to: .event) { (granted, error) in
              completion(granted, error)
          }
      }
    func addEventToCalendar(title: String, startDate: String, endDate: String, location: String?) {
        var dateStart = Date()
        var dateEnd = Date()
        let eventStore = EKEventStore()
        // Create a DateFormatter instance for ISO 8601 format
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date1 = isoDateFormatter.date(from: startDate) {
            // Step 2: Extract date and time components
            let calendar = Calendar.current

            let year = calendar.component(.year, from: date1)
            let month = calendar.component(.month, from: date1)
            let day = calendar.component(.day, from: date1)
            let hour = calendar.component(.hour, from: date1)
            let minute = calendar.component(.minute, from: date1)
            let second = calendar.component(.second, from: date1)

            print("Year: \(year)")
            print("Month: \(month)")
            print("Day: \(day)")
            print("Hour: \(hour)")
            print("Minute: \(minute)")
            print("Second: \(second)")

            // Step 3: Format the Date object to a human-readable string
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium

            let formattedDateString = dateFormatter.string(from: date1)
//            print("Formatted Date and Time: \(formattedDateString)")
            let dateString = formattedDateString

            // Create a DateFormatter instance
            let dateFormatterStart = DateFormatter()

            // Set the date format to match the date string
            dateFormatterStart.dateFormat = "dd MMM yyyy 'at' h:mm:ss a"

            // Optionally, set the locale if necessary
            dateFormatterStart.locale = Locale(identifier: "en_US_POSIX")

            // Convert the string to a Date object
            if let date = dateFormatterStart.date(from: dateString) {
                print("Converted Date: \(date)")
                dateStart = date
            } else {
                print("Failed to parse dateString")
            }
            
        }
        if  let date2 = isoDateFormatter.date(from: endDate) {
            // Step 2: Extract date and time components
            let calendar = Calendar.current

            let year = calendar.component(.year, from: date2)
            let month = calendar.component(.month, from: date2)
            let day = calendar.component(.day, from: date2)
            let hour = calendar.component(.hour, from: date2)
            let minute = calendar.component(.minute, from: date2)
            let second = calendar.component(.second, from: date2)

            print("Year: \(year)")
            print("Month: \(month)")
            print("Day: \(day)")
            print("Hour: \(hour)")
            print("Minute: \(minute)")
            print("Second: \(second)")

            // Step 3: Format the Date object to a human-readable string
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium

            let formattedDateString = dateFormatter.string(from: date2)
            print("Formatted Date and Time: \(formattedDateString)")
            let dateString = formattedDateString

            // Create a DateFormatter instance
            let dateFormatteEend = DateFormatter()

            // Set the date format to match the date string
            dateFormatteEend.dateFormat = "dd MMM yyyy 'at' h:mm:ss a"

            // Optionally, set the locale if necessary
            dateFormatteEend.locale = Locale(identifier: "en_US_POSIX")

            // Convert the string to a Date object
            if let date = dateFormatteEend.date(from: dateString) {
                print("Converted Date: \(date)")
                dateEnd = date
            } else {
                print("Failed to parse dateString")
            }
        }
        else {
            print("Invalid date string")
        }
               // Convert the date strings to Date objects
               let event = EKEvent(eventStore: eventStore)
               event.title = title
               event.startDate = dateStart
               event.endDate = dateEnd
               event.calendar = eventStore.defaultCalendarForNewEvents
               event.location = location
               
               do {
                   try eventStore.save(event, span: .thisEvent)
                   print("Event added to calendar")
               } catch let error {
                   print("Error saving event: \(error.localizedDescription)")
               }
    }

    func setupBasketButton(count: Int) {
        let tintColour = organisationColours.tintColour
        self.basketIconView = BasketIconView(count: count, tintColour: tintColour, basketPressed: { [weak self] () in
            guard let weakSelf = self else { return }
            weakSelf.presenter?.basketButtonPressed()
        })
        self.basketBarButtonItem = UIBarButtonItem(customView: self.basketIconView!)
        
        if(count < 1 || count == nil){
            self.basketIconView?.isHidden = true
        }
        else{
            self.basketIconView?.isHidden = false
        }
        
        setupNavigationItems()
    }
    
    func setTitleFromWebView() {
        if let title = webView?.title {
            self.title = title
        }
    }
    
    func openLinkToNativePage(url: String) {
        delegate?.openLinkToNativePage(url: url)
    }
    
    func gotoCart() {
        delegate?.gotoCart()
    }
    
    func openSafari(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func closePopup() {
        dismiss(animated: true, completion: nil)
    }
    
    func showLoadingErrorPopup() {
        showAlertPopup(title: "Loading Error", message: "There was an error loading this page. Please try again.")
    }
}
// MARK: webview delegate
extension WebContentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            let url = navigationAction.request.url?.absoluteString ?? ""
            let allowNavigation = presenter?.handleLinkActivated(url: url) ?? false
            if allowNavigation == false {
                decisionHandler(.allow)
                return
            } else {
                decisionHandler(.cancel)
                return
            }
        } else if navigationAction.navigationType == .other {
            let url = navigationAction.request.url?.absoluteString ?? ""
            let allowNavigation = presenter?.handleUrlChange(url: url) ?? true
            if allowNavigation == true {
                decisionHandler(.allow)
                return
            } else {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
        return
    }
    func sessionExpiredToLoginVC() {
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
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        presenter?.didStartLoadingUrl()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        setupWebButtons()
        var scriptSource = "adHandler();"
        webView.evaluateJavaScript(scriptSource) { (result, error) in
            if result != nil {
                print(result)
            }
        }
        presenter?.didFinishLoadingUrl()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        presenter?.didFailLoadingUrl()
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        presenter?.didFailLoadingUrl()
        print(error)
    }
}
// MARK: webview Extension
extension WebContentViewController: WKUIDelegate {
    //Fix _blank urls opening in sam wkwebview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
// MARK: webview delegate
extension WebContentViewController : WKScriptMessageHandler,UIWebViewDelegate {
    // https://lumaverse.atlassian.net/wiki/spaces/MTK/pages/279805956/App+-+JS+Communication
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       // send back to MTKAppToJS
//        print(message.body)
//        print(message.name)
        if message.name == "JSToApp" {
            if let jsonString = message.body as? String {
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            // Use the dictionary here
                            if let valueCommand = dictionary["command"] {
                                if valueCommand as! String == "bailto"
                                {
                                  let userData  =  UserResponseJSData(valueCommand as! String, dataContent: dictionary["url"] as! String)
                                    batteryTimer?.invalidate()
                                    batteryTimer = nil
//                                    let terminal = Terminal.shared
                                    // Check if a reader is connected
//                                    if let reader = terminal.connectedReader {
//                                        self.isConnectedReader = true
//                                    } else {
//                                        print("No reader is connected")
//                                    }
//                                    disconnectFromReader()
                                    self.isNFC = false
                                    self.backPOSClick(user: userData)
                                }else
                                {
                                    /// check is logout is receving in JS or not
                                if  valueCommand as! String == "logout"
                                {
                                    presenter?.clearUserDefaults()
                                    self.sessionExpiredToLoginVC()
                                }
                                if valueCommand as! String == "download-file"
                                    {
                                    let userResponse = UserResponseJSDataCE(valueCommand as! String, dataContent: jsonString)

                                    if let dictionary = userResponse.dataContentToDictionary() {
                                        print(dictionary)
                                        let checkMedia = dictionary["mimeType"] as! String
                                        if checkMedia.contains("image/")
                                        {
                                            PHPhotoLibrary.requestAuthorization { status in
                                                switch status {
                                                case .authorized:
                                                    DispatchQueue.main.async {
                                                        self.downloadImageAndSaveToPhotos(from: dictionary["url"] as! String)
                                                    }
                                                case .denied, .restricted:
                            //                        print("Photo library access denied or restricted")
                                                    self.showAlertPopup(title: "Alert", message: "Photo library access denied or restricted")
                                                case .notDetermined:
                            //                        print("Photo library access not determined")
                                                    self.showAlertPopup(title: "Alert", message: "Photo library access not determined")
                                                case .limited:
                                                    self.showAlertPopup(title: "Alert", message: "Photo library access limited,App need full access to save card to photos")
                                                @unknown default:
                                                    fatalError("Unknown photo library authorization status")
                                                }
                                            }
                                         }
                                         else
                                        {
                                             if let url = URL(string: dictionary["url"] as! String) {
                                                  downloadDocument(from: url)
                                              }
                                                
                                        }
                                     }
                                    }
                                if valueCommand as! String == "download-card"
                                {
                                    let userResponse = UserResponseJSDataCE(valueCommand as! String, dataContent: jsonString)

                                    if let dictionary = userResponse.dataContentToDictionary() {

                                       
                                    }
                                }
                                if valueCommand as! String == "get-device-coordinates"
                                {
                                    locationManager.delegate = self
                                    self.permissionLocation()
                                }
                                if  valueCommand as! String == "add-calendar-event"
                                {
                                   
                                    let AlertVC = UIAlertController(title: "Do you want to add event to Calendar?", message: "", preferredStyle: .alert)
                                    let yesAction = UIAlertAction(title: "Add", style: .default) { (action) in
                                        self.requestAccessToCalendar { (granted, error) in
                                                    if granted {
                                                        // If access is granted, add the event
                                                        let userResponse = UserResponseJSDataCE(valueCommand as! String, dataContent: jsonString)

                                                        if let dictionary = userResponse.dataContentToDictionary() {
                                                            print(dictionary["start"])
                                                            // Now you can use the dictionary as needed
                                                        }
                                                        self.addEventToCalendar(title:dictionary["title"] as! String , startDate: dictionary["start"] as! String , endDate: dictionary["end"] as! String, location: dictionary["location"] as! String)
                                                    } else {
                                                        // Handle the error or the case where access is not granted
                                                        self.showAlertPopup(title: "Error", message: "Access to calendar was not granted. Go to settings and enable the permission")
    //                                                    print("Access to calendar was not granted")
                                                        
                                                    }
                                                }
                                    }
                                    AlertVC.addAction(yesAction)
                                    let noAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                                        
                                    }
                                    AlertVC.addAction(noAction)
                                    present(AlertVC, animated: true, completion: nil)
                                }
                                  if valueCommand as! String == "init-payment-sheet"
                                   {
                                      let userData  =  UserPaymentSheetJSData(valueCommand as! String, stripe_publishable_key: dictionary["stripe_publishable_key"] as! String, connected_account_id: dictionary["connected_account_id"] as! String, payment_intent_id: dictionary["payment_intent_id"] as! String,location_id: dictionary["location_id"] as! String,client_secret: dictionary["client_secret"]as! String)
//                                          locationManager.delegate = self
//                                          locationManager.requestAlwaysAuthorization()
//                                         self.PaymentSheet(user: userData)
                                      
                                   }
                                    else if valueCommand as! String == "connect-m2"
                                    {
                                        let userData  =  ReaderConnectData(valueCommand as! String,location_id: dictionary["location_id"] as! String)
                                        MembershipAPIRouter.stripe_Location_Id = dictionary["location_id"] as! String
//                                        if self.isNFC == true
//                                        {
//                                            Terminal.shared.disconnectReader { error in
//                                                if let error = error {
//                                                    print("Disconnect failed: \(error)")
//                                                    self.isReaderDiscoverrconnected = false
//                                                } else {
//                                                    print("disconnected successfully")
//                                                    self.isReaderDiscoverrconnected = false
//                                                }
//                                            }
//                                        }
                                        self.isNFC = false
//                                        self.connectReaderToApp(user: userData)
                                    } else if valueCommand as! String == "check-tap-to-pay-support"
                                    {
//                                        self.checkiOSNFC()
                                    } else if valueCommand as! String == "connect-tap-to-pay"
                                    {
                                       // here make variable true to use tap and pay
                                        self.isNFC = true
                                        let userData  =  ReaderConnectData(valueCommand as! String,
                                        location_id: dictionary["location_id"] as! String)
                                        MembershipAPIRouter.stripe_Location_Id = dictionary["location_id"] as! String
                                        connectionConfigsLcoation = dictionary["location_id"] as! String
                                        batteryTimer?.invalidate()
                                        batteryTimer = nil
//                                        let terminal = Terminal.shared
                                        // Check if a reader is connected
//                                        if let reader = terminal.connectedReader {
//                                            self.isConnectedReader = true
//                                            disconnectFromReader()
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
//                                            {
//                                                do {
//                                                    try self.discoverReadersAction()
//                                                    } catch {
//                                                        print("Error: \(error)")
//                                                    }
//                                            }
//                                        } else {
//                                            do {
//                                                try self.discoverReadersAction()
//                                                } catch {
//                                                    print("Error: \(error)")
//                                                }
//                                        }
//                                       
                                        
                                    }
                                    else if valueCommand as! String == "check-location-services"
                                    {
                                        self.permissionLocation()
                                    }
//                                    else if valueCommand as! String == "cancel-collect-payment"
//                                    {
//                                        let taskCall = Task {
//                                            await self.callCancelPayment()
//                                        }
//                                    }
                                    else if valueCommand as! String == "get-m2-stats"
                                    {
//                                        getBatteryStatus()
                                    }
                                    else if valueCommand as! String == "disconnect-m2"
                                    {
                                        batteryTimer?.invalidate()
                                        batteryTimer = nil
                                        isConnectedReader = true
//                                        disconnectFromReader()
                                           
                                    }
                                    else if valueCommand as! String == "disconnect-tap-to-pay"
                                    {
//                                        if self.isNFC == true
//                                        {
//                                            Terminal.shared.disconnectReader { error in
//                                                if let error = error {
//                                                    print("Disconnect failed: \(error)")
//                                                } else {
//                                                    print("disconnected successfully")
//                                                    self.isDisconnectTapandPay = true
//                                            self.createJsonToPass(status:disconnectTapandPayConstants.disconnectTapandPayResponse)
//                                            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//                                                }
//                                            }
//                                        }
//                                        else
//                                        {
//                                            print("tap and pay is not turn on")
//                                        }
                                           
                                    }
                                }
                            }
                            else
                            {
                                
                            }
                        }
                    } catch {
                        print("Error converting message.body to dictionary: \(error.localizedDescription)")
                    }
                }
            }
        }
        else
        {
            guard let dictionary =  message.body as? [String: Any] else { return }
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
            let ad = try! JSONDecoder().decode(NativeAd.self, from: jsonData)
            if(ad != nil){
                
                self.showAds(ad: ad)
            }
        }
       
    }
    //
    
    // .........here download membership card.......
    func downloadDocument(from url: URL) {
        self.showLoader(withTitle: "Downloading File...")

            let urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let downloadTask = urlSession.downloadTask(with: url) { localURL, response, error in
                   guard let localURL = localURL, error == nil else {
                       print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                       return
                   }

                        do {
                           let fileManager = FileManager.default
                            let downloadsURL = try fileManager.url(for: .documentationDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                           let folderURL = downloadsURL.appendingPathComponent("MyDownloads", isDirectory: true)

                           // Create the folder if it doesn't exist
                           if !fileManager.fileExists(atPath: folderURL.path) {
                               try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                           }

                           let savedURL = folderURL.appendingPathComponent(url.lastPathComponent)

                           // Remove the existing file if it exists
                           if fileManager.fileExists(atPath: savedURL.path) {
                               try fileManager.removeItem(at: savedURL)
                           }

                           // Move the downloaded file to the target location
                           try fileManager.moveItem(at: localURL, to: savedURL)

                           print("File saved to: \(savedURL)")
                            DispatchQueue.main.async {
                                self.hideLoader()
                                self.showSavedFileAlert(fileURL: savedURL)
                            }
                       } catch {
                           print("File saving error: \(error.localizedDescription)")
                       }
                   }

                   downloadTask.resume()
        }
        func showLoader(withTitle title: String) {
            docLoader = UIAlertController(title: title, message: nil, preferredStyle: .alert)
//            let indicator = UIActivityIndicatorView(style: .large)
//            indicator.center = CGPoint(x: 135.0, y: 65.5)
//            indicator.color = .gray
//            indicator.startAnimating()
//
//            docLoader?.view.addSubview(indicator)
            
            if let loader = docLoader {
                present(loader, animated: true, completion: nil)
            }
        }
        
        func hideLoader() {
            docLoader?.dismiss(animated: true, completion: nil)
        }

        func showSavedFileAlert(fileURL: URL) {
            let alert = UIAlertController(title: "File has been dowloaded", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.openFile(fileURL: fileURL)
            }))
            self.present(alert, animated: true, completion: nil)
        }
      func openFile(fileURL: URL) {
          DispatchQueue.main.async {
              let documentInteractionController = UIDocumentInteractionController(url: fileURL)
              documentInteractionController.delegate = self
              documentInteractionController.presentPreview(animated: true)
          }
        }
    
    // .........here download membership card.......
    func downloadImageAndSaveToPhotos(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        DispatchQueue.main.async {
            // Download the image data
            let alert = UIAlertController(title: nil, message: "Downloading ...", preferredStyle: .alert)

//            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//            loadingIndicator.hidesWhenStopped = true
//            loadingIndicator.style = UIActivityIndicatorView.Style.medium
//            loadingIndicator.startAnimating();
//            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                        self.showAlertPopup(title: "Error", message: "Error downloading image: \(error)")
                    }
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Failed to load image data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                        self.showAlertPopup(title: "Error", message: "Failed to load image data")
                    }
                    return
                }
                
                // Save the image to the photo library
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        DispatchQueue.main.async {
                            self.dismiss(animated: false, completion: nil)
                        }
                        print("Image successfully saved to photos")
                        self.showAlertPopup(title: "Alert", message: "Card successfully saved to Photos")
                    } else if let error = error {
                        print("Error saving image to photos: \(error)")
                        DispatchQueue.main.async {
                            self.dismiss(animated: false, completion: nil)
                            self.showAlertPopup(title: "Error", message: "Error saving image to photos: \(error)")
                        }
                    }
                }
            }.resume()
        }
    }

    func dismissProgressAlert() {
            progressAlertController.dismiss(animated: true, completion: nil)
        }

    // MARK: webView Methods
//    func connectReaderToApp(user:ReaderConnectData)
//    {
//        connectionConfigsLcoation = user.location_id!
//        self.readerPowerTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(sendNoReaderStatus), userInfo: nil, repeats: true)
//        self.elapsedTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
//        callAlertConnectReader()
//        do {
//            try self.discoverReadersAction()
//            } catch {
//                print("Error: \(error)")
//            }
//    }
    // MARK: reader offline status
    @objc func timerTick() {
           // Increment the elapsed time by 1 second
           elapsedTime += 1.0
        if elapsedTime >= 19.0
        {
            elapsedTime = 19.0
            self.elapsedTimer?.invalidate()
            self.elapsedTimer = nil
         }
       }
    @objc func sendNoReaderStatus() {
        DispatchQueue.main.async {
            self.alertPaymentController.dismiss(animated: true, completion: nil)
        }
//        let taskCall = Task {
//            await self.cancelDiscoverAction()
//        }
//        let terminal = Terminal.shared
//        if terminal.connectionStatus == .connecting {
//            self.isReaderDiscoverrconnected = true
//        }
        self.elapsedTimer?.invalidate()
        self.elapsedTimer = nil
        self.isConnectedReader = true
        self.readerPowerTimer?.invalidate()
        self.readerPowerTimer = nil
        self.elapsedTimer?.invalidate()
        self.elapsedTimer = nil
        self.createJsonToPass(status:readerConstants.cancel)
        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
//        self.createJsonToPass(status:readerConstants.cancel)
//        self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
       
        
    }
    func backPOSClick(user:UserResponseJSData){
        MembershipAPIRouter.storeURL = nil
        addWebView()
        if let url = URL(string: user.dataContent!) {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        }
    }
    // MARK: checkout Payment sheet
//    func PaymentSheet(user:UserPaymentSheetJSData){
//       
//        STPAPIClient.shared.publishableKey = user.stripe_publishable_key!
//        MembershipAPIRouter.stripe_Client_Secret =  user.client_secret!
//        self.paymentIntentId = user.payment_intent_id!
////        self.permissionLocation()
//        if self.statusLocation == true
//        {
//            checkoutButtonAction()
//        }
//    }
    // MARK: javaScript callBack
    func createJsonForJavaScript(for data: [String : Any]) -> String {
        var jsonString : String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
                
            jsonString = String(data: jsonData, encoding: .utf8)!
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString!)
        return jsonString!
    }
    // MARK: create JSON String send to JS layer
    func createJsonToPass(status : String) {
        if status == "send-coordinates"
        {
            let data = [locationConstantsCE.command:locationConstantsCE.locationServiceResponse,locationConstantsCE.isSuccess:"true",locationConstantsCE.latitude:latitudeStore,locationConstantsCE.longitude:longitudeStore] as [String : Any]
            self.jsonStringToPass = createJsonForJavaScript(for: data)
            self.locationallowed = true
            self.locationManager.stopUpdatingLocation()
        }
        if status == "cancel-collect-payment-response"
        {
            if isCancelPaymentError == true
            {
                
//                let data = [paymentConstants.command:paymentConstants.cancelPaymentResponse,paymentConstants.statusStr:"error",paymentConstants.paymentIntentId:self.paymentIntentId,paymentConstants.error_code:self.sdkErrorCode ?? 0,paymentConstants.error_desc :self.paymentFailed ?? ""] as [String : Any]
//                self.jsonStringToPass = createJsonForJavaScript(for: data)
//                self.isCancelPaymentError = false
            }
            else
            {
                let data = [paymentConstants.command:paymentConstants.cancelPaymentResponse,paymentConstants.statusStr:"success",paymentConstants.paymentIntentId:self.paymentIntentId] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
           
        }
        if status == "tap-to-pay-support-response"
        {
            let data = [NFCConstants.command:NFCConstants.checkTapAndPayResponse,NFCConstants.statusStr : self.isNFCCompatible]
            self.jsonStringToPass = createJsonForJavaScript(for: data)
            
        }
        if status == "disconnect-tap-to-pay-response"
        {
            if self.isDisconnectTapandPay == true
            {
                let data = [disconnectTapandPayConstants.command:disconnectTapandPayConstants.disconnectTapandPayResponse,disconnectTapandPayConstants.status : "success"]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
                self.isDisconnectTapandPay = false
            }
            else
            {
                let data = [disconnectTapandPayConstants.command:disconnectTapandPayConstants.disconnectTapandPayResponse,disconnectTapandPayConstants.status : "error"]
                self.jsonStringToPass = createJsonForJavaScript(for: data)

            }
           
            
        }
        if status == "connect-tap-to-pay-response"
        {
            if self.NFCStatus == "error"
            {
                let data = [ConnectNFCConstants.command:ConnectNFCConstants.ConnectNFCResponse,ConnectNFCConstants.statusStr:self.NFCStatus,readerConstants.error_desc : self.readerDescription ?? ""] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
                
            }
            if self.NFCStatus == "cancel"
            {
                 let data = [ConnectNFCConstants.command:ConnectNFCConstants.ConnectNFCResponse,ConnectNFCConstants.statusStr:self.NFCStatus] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
                                   
            }
            else
            {
                let data = [ConnectNFCConstants.command:ConnectNFCConstants.ConnectNFCResponse,ConnectNFCConstants.statusStr:self.NFCStatus] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
        }
        if status == "Y" || status == "N"
        {
            let data = [locationConstants.command:locationConstants.locationServiceResponse,locationConstants.isServiceEnabled:status] as [String : Any]
            self.jsonStringToPass = createJsonForJavaScript(for: data)
        }
        if isBluetoothError == true
        {
//            let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:"error",readerConstants.error_code:self.sdkErrorCode ?? 0,readerConstants.error_desc :self.readerDescription ?? ""] as [String : Any]
//                isBluetoothError = false
//                self.jsonStringToPass = createJsonForJavaScript(for: data)
        }
        if isConnectedReader == true
        {
            if status == "failed"
            {
//                let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:"error",readerConstants.response:self.failedConnectReaderInfo,readerConstants.error_code:self.sdkErrorCode ?? 0,readerConstants.error_desc :self.readerDescription ?? ""] as [String : Any]
//                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
            if status == "error"
            {
                let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:"error",readerConstants.error_code:"TIMEOUT",readerConstants.error_desc : self.readerDescription ?? ""] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
             if status == "cancel"
            {
                 print(elapsedTime)
                 if elapsedTime < 19.0 {
                     elapsedTime = 0.0
                     let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:status] as [String : Any]
                     self.jsonStringToPass = createJsonForJavaScript(for: data) // {  "command" : "connect-m2-response",  "status" : "cancel"}
                 }
                 else
                 {
                     elapsedTime = 0.0
                     let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:"error",readerConstants.error_code:"TIMEOUT",readerConstants.error_desc :self.readerDescription ?? ""] as [String : Any]
                     self.jsonStringToPass = createJsonForJavaScript(for: data)
                    
                 }
               
            }
            else
            {
                let data = [readerConstants.command:readerConstants.connectM2Reader,readerConstants.status:status,readerConstants.reader:readerDataInfo] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
            self.isConnectedReader = false
            
        }
        if self.readerDisconnectStatus == true
        {
            self.readerDisconnectStatus = false
            if  self.readerDisconnectUnexpectedlyStatus == true
            {
                let data = [M2EventConstants.command:readerConstantsDisconnect.connectM2ReaderDisconnect,readerConstantsDisconnect.status : "success"]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
            else
            {
                let data = [M2EventConstants.command:readerConstantsDisconnect.connectM2ReaderDisconnect,readerConstantsDisconnect.status : "success"]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
            }
            
        }
        if isPayment == true {
//            DispatchQueue.main.async {
//                self.alertPaymentController.dismiss(animated: true, completion: nil)
//            }
            if status == "error"
            {
                if self.paymentFailed.contains("'") {
                    let pattern = "'."

                    // Create a regular expression object
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        let range = NSRange(location: 0, length: paymentFailed.utf16.count)
                        let stringWithoutApostrophes = regex.stringByReplacingMatches(in: paymentFailed, options: [], range: range, withTemplate: "")
                        self.paymentFailed = stringWithoutApostrophes
                        print(self.paymentFailed) // Output: without apostrophe"
                    }
                }
//                let data = [paymentConstants.command:paymentConstants.paymentResponse,paymentConstants.statusStr:status,paymentConstants.paymentIntentId:self.paymentIntentId,paymentConstants.error_desc :self.paymentFailed,readerConstants.error_code:self.sdkErrorCode ?? 0] as [String : Any]
//                self.jsonStringToPass = createJsonForJavaScript(for: data as [String : Any])
            }
            if status == "payment Cancelled"
            {
                let data = [paymentConstants.command:paymentConstants.paymentResponse,paymentConstants.statusStr:paymentConstants.statusCancel] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data as [String : Any])
            }
            if status != "error" && status != "payment Cancelled"
            {
                let data = [paymentConstants.command:paymentConstants.paymentResponse,paymentConstants.statusStr:status,paymentConstants.paymentIntentId:self.paymentIntentId,paymentConstants.paymentResponseJson :paymentResponseData] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data as [String : Any])
            }
            self.isPayment = false
        }
        if self.isReaderInfo == true
        {
            self.isReaderInfo = false
            print(isReaderInfo,self.batteryCount)
            let data = [M2EventConstants.command:M2EventConstants.m2_event,M2EventConstants.event:M2EventConstants.readerbatteryUpdate,M2EventConstants.readerbatteryPer:self.batteryCount] as [String : Any]
                self.jsonStringToPass = createJsonForJavaScript(for: data)
        }
        print(jsonStringToPass)
        
    }
    
}
struct SomeStruct: Codable {
    let id: String
}

// MARK: - Location extension
//extension Location {
//    var displayString: String {
//        return self.displayName ?? self.stripeId
//    }
//}
// MARK: reader Reconnect
//extension WebContentViewController: ReconnectionDelegate {
//    func reader(_ reader: Reader, didStartReconnect cancelable: Cancelable) {
//        print("reconnecting...")
//    }
//
//    func readerDidFailReconnect(_ reader: Reader) {
//        print("failed to reconnecting...")
//    }
//
//    func readerDidSucceedReconnect(_ reader: Reader) {
//        print("reconnected successfully...")
//    }
//}
extension WebContentViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
extension WebContentViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var accuracyAuthorization = manager.accuracyAuthorization
        if accuracyAuthorization == CLAccuracyAuthorization.reducedAccuracy
        {
            //this is the case where precise location is off
            print("precise is off")
        }
        else if accuracyAuthorization == CLAccuracyAuthorization.fullAccuracy
        {
            //this is the case where precise location is on
            print("precise is on")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
     print(error)
     }

     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     // .requestLocation will only pass one location to the locations array
     // hence we can access it by taking the first element of the array
         locationManager.desiredAccuracy = 100
         if let location = locations.first {
         print(location.coordinate.latitude)
         print(location.coordinate.longitude)
             latitudeStore = location.coordinate.latitude
         longitudeStore = location.coordinate.longitude
         self.createJsonToPass(status: locationConstantsCE.locationServiceResponse)

      }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch manager.authorizationStatus {
            case .authorizedAlways:
            self.statusLocation = true
            self.locationallowed = true
            break
            // Handle case
            case .authorizedWhenInUse:
            self.statusLocation = true
            self.locationallowed = true
            break
            // Handle case
        case .denied,.restricted:
            print("permission denied or restricted")
            self.showAlertPopup(title: "Alert", message: "permission denied or restricted for Location")
//            self.createJsonToPass(status: locationConstants.isN)
//            self.webView?.evaluateJavaScript("MTKAppToJS('\(self.jsonStringToPass)')")
            self.statusLocation = false
            self.locationallowed = false
            break
        case .notDetermined:
            print("permission unidentified")
//            self.requestLocationPermission()
            self.statusLocation = false
            self.locationallowed = false
            break
            // Handle case
            @unknown default:
            break
        }
    }
}
