//
//  DirectoryDetailPersonCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol DirectoryDetailPersonCellDelegate: class {
    func didPressField(fieldView: DirectoryFieldView, field: DirectoryEntryField, sourceFrame: CGRect)
    func didPressAddContact(person: DirectoryEntryPerson, imageData: Data?)
}

class DirectoryDetailPersonCell: UITableViewCell {
    
    var organisationColours: OrganisationColours!
    var firstName: String?
    var lastName: String?
    var profileImage: String?
    weak var delegate: DirectoryDetailPersonCellDelegate?
    var person: DirectoryEntryPerson?
    var profileImageData: Data?
    
    @IBOutlet weak var profileThumbWrapper: UIView!
    @IBOutlet weak var fieldsStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTitleStackView: UIStackView!
    @IBOutlet weak var addContactBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(person: DirectoryEntryPerson, sectionHeaderLabel: String, otherLabels: DirectoryEntryLabels?) {
        self.person = person
        
        nameLabel.textColor = UIColor.mtMatteBlack
        nameLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        
        profileImageView.layer.cornerRadius = 5
        
        setupFieldsStackView(fields: person.fields)
        
        setupProfileImage()
        setupNameLabel()
        
        addContactBtn.tintColor = UIColor.mtBrandBlueDark
    }
    
    fileprivate func setupFieldsStackView(fields: Array<DirectoryEntryField>) {
        removeAllFields()
        
        self.profileImage = nil
        self.firstName = nil
        self.lastName = nil
        
        //remove old seperate address fields
        let seperateAddressNames = ["address", "city", "state", "zip", "address2", "city2", "state2", "zip2"]
        let filteredFields = fields.filter({ (existingField) -> Bool in
            guard let existingFieldName = existingField.name else { return false }
            return !seperateAddressNames.contains(existingFieldName)
        })
        
        for field in filteredFields {
            //Pull out image and names and then show other fields
            if field.name == "avatar_url" || field.name == "avatar_url2" {
                if let value = field.value {
                    profileImage = value
                }
            } else if field.name == "firstname" || field.name == "firstname2" {
                firstName = field.value
            } else if field.name == "lastname" || field.name == "lastname2" {
                lastName = field.value
            } else {
                let fieldView = DirectoryFieldView()
                fieldView.delegate = self
                fieldView.organisationColours = self.organisationColours
                fieldView.configure(field: field)
                fieldsStackView.addArrangedSubview(fieldView)
            }
        }
    }
    
    fileprivate func removeAllFields() {
        for field in fieldsStackView.arrangedSubviews {
            field.removeFromSuperview()
        }
    }
    
    fileprivate func setupProfileImage() {
        if let profileImageString = self.profileImage {
            profileThumbWrapper.isHidden = false

            if let imageUrl = URL(string: profileImageString) {
                profileImageView.kf.setImage(with: imageUrl, placeholder: ImagePlaceholderView(), options: [.transition(.fade(0.2))]) { (result) in
                    switch result {
                    case .success(let value):
                        if let imageData = value.image.jpegData(compressionQuality: 1) {
                            self.profileImageData = imageData
                        }
                    default:
                        self.profileImageData = nil
                    }
                }
            }
        } else {
            profileThumbWrapper.isHidden = true
        }
    }
    
    fileprivate func setupNameLabel() {
        var namesArray = Array<String>()
        if let firstName = self.firstName {
            namesArray.append(firstName)
        }
        if let lastName = self.lastName {
            namesArray.append(lastName)
        }
        let nameString = namesArray.joined(separator: " ")
        if nameString.count > 0 {
            nameLabel.text = nameString
            nameLabel.isHidden = false
        } else {
            nameLabel.isHidden = true
        }
    }
    
    @IBAction func addContactBtnPressed(_ sender: Any) {
        guard let person = self.person else { return }
        
        delegate?.didPressAddContact(person: person, imageData: profileImageData)
    }
}

extension DirectoryDetailPersonCell: DirectoryFieldViewDelegate {
    func didPressField(fieldView: DirectoryFieldView, field: DirectoryEntryField, sourceFrame: CGRect) {
        delegate?.didPressField(fieldView: fieldView, field: field, sourceFrame: sourceFrame)
    }
}
