//
//  popupViewController.swift
//  ClubExpress
//
//  Created by Ronit Patel on 23/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import UIKit
//import StripeCore

protocol popupViewControllerDelegate: AnyObject {
    func popupViewControllerDidFinishWithValue(status: String,paymentDataStr:String)
}
class popupViewController: UIViewController {

//    lazy var cardTextField: STPPaymentCardTextField = {
//        let cardTextField = STPPaymentCardTextField()
//        return cardTextField
//    }()
//    lazy var payButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.layer.cornerRadius = 5
//        button.backgroundColor = .systemBlue
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
//        button.setTitle("Pay", for: .normal)
//        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
//        return button
//    }()
//    lazy var cancelButton: UIButton = {
//           let button = UIButton(type: .system)
//           button.setTitle("Cancel", for: .normal)
//           button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
//           return button
//       }()
//    var paymentIntentClientSecret: String?
//    var paymentStatus: String!
//    var paymentData = String()
//    weak var delegate: popupViewControllerDelegate?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
//        stackView.axis = .vertical
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        view.addSubview(cancelButton)
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//                   cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//                   cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//        ])
//        NSLayoutConstraint.activate([
//               stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//               stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//               stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//               stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//               cardTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1),
//               payButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
//               payButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 35),
//               cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//               cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//        ])
//        paymentIntentClientSecret = MembershipAPIRouter.stripe_Client_Secret
//        StripeAPI.defaultPublishableKey = MembershipAPIRouter.stripe_publishable_key ?? ""
//        STPAPIClient.shared.stripeAccount = MembershipAPIRouter.stripe_ConnectedAccount_Id ?? ""
//
//        // Do any additional setup after loading the view.
//    }
//    @objc func cancelButtonTapped() {
//            // Handle the cancel button tap event
//            dismiss(animated: true, completion: nil)
//        }
//    func dismissPopupViewController() {
//           delegate?.popupViewControllerDidFinishWithValue(status: paymentStatus,paymentDataStr: paymentData)
//           dismiss(animated: true, completion: nil)
//       }
//      
//    // Validate card number
//    func isValidCardNumber(cardNumber: String) -> Bool {
//        let cardNumberRegex = "^[0-9]{13,19}$"
//        let cardNumberPredicate = NSPredicate(format: "SELF MATCHES %@", cardNumberRegex)
//        return cardNumberPredicate.evaluate(with: cardNumber)
//    }
//
//    // Validate CVV
//    func isValidCVV(cvv: String) -> Bool {
//        let cvvRegex = "^[0-9]{3,4}$"
//        let cvvPredicate = NSPredicate(format: "SELF MATCHES %@", cvvRegex)
//        return cvvPredicate.evaluate(with: cvv)
//    }
//
//    // Validate expiration month/year
//    func isValidExpirationDate(expirationMonth: Int, expirationYear: Int) -> Bool {
//        let currentYear = Calendar.current.component(.year, from: Date()) % 100
//        if expirationYear < currentYear {
//            return false
//        } else if expirationYear == currentYear {
//            let currentMonth = Calendar.current.component(.month, from: Date())
//            if expirationMonth < currentMonth {
//                return false
//            }
//        }
//        return true
//    }
//
//    // Validate zip code
//    func isValidZipCode(zipCode: String) -> Bool {
//        let zipCodeRegex = "^[0-9]{5}$"
//        let zipCodePredicate = NSPredicate(format: "SELF MATCHES %@", zipCodeRegex)
//        return zipCodePredicate.evaluate(with: zipCode)
//    }
//    @objc func pay() {
//          let cardNumber = cardTextField.cardNumber ?? ""
//          let cvv = cardTextField.cvc ?? ""
//          let expirationMonth = cardTextField.expirationMonth
//          let expirationYear = cardTextField.expirationYear
//          let zipCode = cardTextField.postalCode ?? ""
//          
//      if !isValidCardNumber(cardNumber: cardNumber) {
//          print("card number is invalid")
//          // Handle invalid card number
//          return
//      }
//      
//      if !isValidCVV(cvv: cvv) {
//          print("cvv is invalid")
//          // Handle invalid CVV
//          return
//      }
//      
//      if !isValidExpirationDate(expirationMonth: expirationMonth, expirationYear: expirationYear) {
//          // Handle invalid expiration date
//          print("card month/year is invalid")
//          return
//      }
//      
//      if !isValidZipCode(zipCode: zipCode) {
//          print("zipcode is invalid")
//          // Handle invalid zip code
//          return
//      }
//          else
//          {
//              guard let paymentIntentClientSecret = paymentIntentClientSecret else {
//                  return
//              }
//              // Collect card details
//              let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
//              paymentIntentParams.paymentMethodParams = cardTextField.paymentMethodParams
//
//              // Submit the payment
//              let paymentHandler = STPPaymentHandler.shared()
//              paymentHandler.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
//                  switch (status) {
//                  case .failed:
//                      print("Payment failed",error?.localizedDescription ?? "")
//                      let errorStr = error!.localizedDescription
//                      self.showAlertPopup(title: "Error", message: "Payment Failed : \(errorStr)")
//                      self.paymentStatus = paymentConstants.statuFailed
//                      break
//                  case .canceled:
//                      print("Payment canceled",error?.localizedDescription ?? "")
//                      self.paymentStatus = paymentConstants.statusCancel
//                      break
//                  case .succeeded:
////                      self.displayAlert(title: "Payment succeeded", message: paymentIntent?.description ?? "", restartDemo: true)
//                      print("Payment succeeded",paymentIntent?.description ?? "")
//                      self.paymentStatus = paymentConstants.statusSuccess
//                      let paymentString = paymentIntent?.description
//                      let keyValuePairs = paymentString!
//                          .components(separatedBy: "; ")
//                          .map { $0.components(separatedBy: " = ") }
//                          .reduce(into: [String: String]()) { result, pair in
//                              if pair.count == 2 {
//                                  let key = pair[0].trimmingCharacters(in: .whitespacesAndNewlines)
//                                  let value = pair[1].trimmingCharacters(in: .whitespacesAndNewlines)
//                                  result[key] = value
//                              }
//                          }
//
//                      // Convert to JSON data
//                      do {
//                          let jsonData = try JSONSerialization.data(withJSONObject: keyValuePairs, options: .prettyPrinted)
//                          if let jsonString = String(data: jsonData, encoding: .utf8) {
//                              self.paymentData = jsonString
//                              self.dismissPopupViewController()
//                          }
//                      } catch {
//                          print("Error encoding key-value pairs to JSON: \(error)")
//                          self.showAlertPopup(title: "Error", message: "Payment Failed : \(error)")
//                      }
//                      break
//                  @unknown default:
//                      fatalError()
//                      break
//                  }
//              }
//          }
//      }

}
//extension popupViewController: STPAuthenticationContext {
//    func authenticationPresentingViewController() -> UIViewController {
//        return self
//    }
//}

