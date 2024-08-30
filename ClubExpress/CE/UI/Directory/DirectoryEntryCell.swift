//
//  DirectoryEntryCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 15/01/2019.
//  
//

import UIKit

class DirectoryEntryCell: UITableViewCell {

    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var favouritedIcon: UIImageView!
    @IBOutlet weak var favouritedIconWrapper: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        primaryLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        secondaryLabel.font = UIFont.openSansFontOfSize(size: 15)
        
        primaryLabel.textColor = UIColor.mtMatteBlack
        secondaryLabel.textColor = UIColor.mtSlateGrey
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(entry: DirectoryEntry) {
        setPrimaryLabelText(entry: entry)
        setSecondaryLabelText(entry: entry)
        
        configureConstraints()
        
        let isFavourited = entry.isFavourite ?? false
        configureFavouriteIcon(isFavourited: isFavourited)
    }

    fileprivate func setPrimaryLabelText(entry: DirectoryEntry) {
       
        if let primaryLabelText = entry.row1Text {
            primaryLabel.text = "\(primaryLabelText)"
        } else {
            primaryLabel.text = "No Name"
        }
    }
    
    fileprivate func setSecondaryLabelText(entry: DirectoryEntry) {
        
        if let secondaryLabelText = entry.row2Text {
            secondaryLabel.text = "\(secondaryLabelText)"
        } else {
            secondaryLabel.text = ""
        }
    }
    
    func configureConstraints() {
        if secondaryLabel.text == "" {
            secondaryLabel.isHidden = true
        } else {
            secondaryLabel.isHidden = false
        }
    }
    
    func configureFavouriteIcon(isFavourited: Bool) {
        if isFavourited {
            favouritedIconWrapper.isHidden = false
        } else {
            favouritedIconWrapper.isHidden = true
        }
    }
}
