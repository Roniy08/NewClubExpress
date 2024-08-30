//
//  SelectOrganisationController.swift
//  CE
//
//  Created by Ronit Patel on 13/06/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

import UIKit
import iOSDropDown

class SelectOrganisationController: UIViewController {
    
    @IBOutlet weak var dropDowns : DropDown!
    var cardNamesArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        dropDowns.optionIds = []
        dropDowns.checkMarkEnabled = false
        dropDowns.semanticContentAttribute = .forceLeftToRight
        dropDowns.textColor = .black
        dropDowns.isSearchEnable = false
                dropDowns.didSelect { selectedText, index, id in
                    print("Selected String: \(selectedText) \n index: \(index) \n Id: \(id)")
                // Do any additional setup after loading the view.
            }
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
