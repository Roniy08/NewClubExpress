//
//  DirectoryFilterCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol DirectoryFilterCellDelegate: class {
    func didChangeFilterOption(filter: DirectoryFilter, option: DirectoryFilterOption?)
}

class DirectoryFilterCell: UITableViewCell {

    var organisationColours: OrganisationColours!
    weak var delegate: DirectoryFilterCellDelegate?
    fileprivate var picker = UIPickerView()
    fileprivate var toolbar = UIToolbar()
    fileprivate var filter: DirectoryFilter?
    fileprivate var selectedOption: DirectoryFilterOption?
    
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var filterValueTF: FilterValueTextField!
    @IBOutlet weak var dropdownWrapper: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filterNameLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        
        clearBtn.titleLabel?.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
        clearBtn.setTitleForAllStates(title: "Clear")
        
        dropdownWrapper.layer.cornerRadius = 6
        
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarBtnPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        filterValueTF.tintColor = UIColor.clear
        
        picker.delegate = self
        picker.dataSource = self
        filterValueTF.inputView = picker
        filterValueTF.inputAccessoryView = toolbar
        filterValueTF.delegate = self
        filterValueTF.font = UIFont.openSansFontOfSize(size: 16)
        filterValueTF.textColor = UIColor.mtBrandBlueDark
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(filter: DirectoryFilter, selectedOption: DirectoryFilterOption?) {
        self.filter = filter
        self.selectedOption = selectedOption
        
        if let filterLabel = filter.label {
            filterNameLabel.text = filterLabel
        }
        
        if let selectedOption = selectedOption {
            if let optionName = selectedOption.name {
                filterValueTF.text = optionName
            }
            clearBtn.isHidden = false
            clearBtn.isEnabled = true
            
            //Select correct row in picker
            let selectedIndexInOptions = filter.options?.firstIndex(where: { (option) -> Bool in
                return option.value == selectedOption.value
            })
            if let selectedIndexInOptions = selectedIndexInOptions {
                picker.selectRow(selectedIndexInOptions, inComponent: 0, animated: false)
            }
        } else {
            if let filterLabel = filter.label {
                filterValueTF.text = ""
                filterValueTF.placeholder = "Choose \(filterLabel)"
            }
            clearBtn.isHidden = true
            clearBtn.isEnabled = false
            
            picker.selectRow(0, inComponent: 0, animated: false)
        }
        
        filterNameLabel.textColor = organisationColours.textColour
        clearBtn.setTitleColourForAllStates(colour: organisationColours.textColour)
        toolbar.tintColor =  organisationColours.isPrimaryBgColourDark ? organisationColours.primaryBgColour : UIColor.mtMatteBlack

    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        self.selectedOption = nil
        filterValueTF.resignFirstResponder()

        guard let filter = self.filter else { return }
        delegate?.didChangeFilterOption(filter: filter, option: nil)
    }
    
    @objc func doneBarBtnPressed(button: UIBarButtonItem) {
        filterValueTF.resignFirstResponder()
    }
    
    fileprivate func commitChange() {
        guard let filter = self.filter else { return }
        guard let selectedOption = self.selectedOption else { return }
        delegate?.didChangeFilterOption(filter: filter, option: selectedOption)
    }
}

extension DirectoryFilterCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let filter = self.filter else { return 0 }
        guard let options = filter.options else { return 0 }
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let filter = self.filter else { return nil }
        guard let options = filter.options else { return nil }
        if row >= 0 && row < options.count {
                let option = options[row]
                return option.name
            } else {
                return nil
            }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let filter = self.filter else { return }
        guard let options = filter.options else { return }
        let option = options[row]
        
        self.selectedOption = option
        
        if let optionName = option.name {
            filterValueTF.text = optionName
        }
    }
}

extension DirectoryFilterCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        picker.delegate = self
        picker.dataSource = self
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        commitChange()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
