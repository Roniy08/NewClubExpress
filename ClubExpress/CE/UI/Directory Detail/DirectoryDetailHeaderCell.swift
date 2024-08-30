//
//  DirectoryDetailHeaderCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class DirectoryDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(label: String) {
        headerLabel.text = label
        headerLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 18)
        headerLabel.textColor = UIColor.mtMatteBlack
    }
}
