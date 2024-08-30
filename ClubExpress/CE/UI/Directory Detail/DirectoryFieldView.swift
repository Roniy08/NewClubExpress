//
//  DirectoryFieldView.swift
//
//
//  Created by Ronit on 05/06/2024.
//

import Foundation
import UIKit



protocol DirectoryFieldViewDelegate: class {
    func didPressField(fieldView: DirectoryFieldView, field: DirectoryEntryField, sourceFrame: CGRect)
}

class DirectoryFieldView: XibView {
    
    var organisationColours: OrganisationColours!
    weak var delegate: DirectoryFieldViewDelegate?
    var field: DirectoryEntryField?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueButton: ButtonWithInsets!
    
    override func xibSetup() {
        super.xibSetup()
        
        titleLabel.textColor = UIColor.mtBrandBlueDark
        titleLabel.font = UIFont.openSansBoldFontOfSize(size: 12)
        
        valueButton.titleLabel?.font = UIFont.openSansFontOfSize(size: 15)
        valueButton.setTitleColourForAllStates(colour: UIColor.mtSlateGrey)
        valueButton.layer.cornerRadius = 4
        valueButton.clipsToBounds = true
    }
    
    func configure(field: DirectoryEntryField) {
        self.field = field
        
        if let title = field.label {
            titleLabel.text = title.uppercased()
        }
        
        if let value = field.value {
            valueButton.setTitleForAllStates(title: value)
        }
        
        let fieldType = field.type ?? .text
        styleField(type: fieldType)
    }
    
    fileprivate func styleField(type: directoryEntryFieldType) {
        if type == .phone || type == .email || type == .address {
            valueButton.backgroundColor = organisationColours.primaryBgColour.withAlphaComponent(0.08)
            valueButton.isEnabled = true
            valueButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            valueButton.tintColor = organisationColours.primaryBgColour
        } else {
            valueButton.isEnabled = false
            valueButton.backgroundColor = UIColor.clear
            valueButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            valueButton.tintColor = UIColor.mtSlateGrey
        }
    }
    
    @IBAction func valueBtnPressed(_ button: UIButton) {
        guard let field = self.field else { return }
        
        let buttonFrame = button.frame
        
        delegate?.didPressField(fieldView: self, field: field, sourceFrame: buttonFrame)
    }
}
