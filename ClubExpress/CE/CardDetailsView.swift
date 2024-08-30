//
//  CardDetailsView.swift
// ClubExpress
//
//  Created by Ronit Patel on 20/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import UIKit

//import StripePaymentsUI

class CardDetailsView: UIViewController {

//    private var cardTextField: STPPaymentCardTextField!
//    private var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
    }
    
    /* private func setupUI() {
        // Card TextField
        cardTextField = STPPaymentCardTextField(frame: CGRect(x: 20, y: 100, width: 300, height: 44))
        view.addSubview(cardTextField)
        
        // Submit Button
        submitButton = UIButton(type: .system)
        submitButton.frame = CGRect(x: 20, y: 200, width: 100, height: 44)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
    }
    
    @objc private func submitButtonTapped() {
        let cardParams = cardTextField.cardParams
        if STPCardValidator.validationState(forCard: cardParams) == .valid {
            // Card details are valid, proceed with payment
            let cardNumber = cardParams.number
            let expirationMonth = cardParams.expMonth
            let expirationYear = cardParams.expYear
            let cvc = cardParams.cvc
            
            // Call the appropriate payment method or API using the card details
            print("Card Number: \(cardNumber)")
            print("Expiration Month: \(expirationMonth)")
            print("Expiration Year: \(expirationYear)")
            print("CVC: \(cvc)")
        } else {
            // Card details are invalid, display error message
            print("Invalid card details")
        }
     }*/
        // Do any additional setup after loading the view.

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
