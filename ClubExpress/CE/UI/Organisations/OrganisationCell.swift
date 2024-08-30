//
//  OrganisationCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit
import Kingfisher

class OrganisationCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notificationCountView: UIView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var notificationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        nameLabel.textColor = UIColor.mtMatteBlack
        
        notificationCountLabel.font = UIFont.openSansBoldFontOfSize(size: 10)
        notificationCountLabel.textColor = UIColor.white
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
        
        notificationCountView.layer.cornerRadius = notificationCountView.frame.size.width/2
        notificationCountView.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text  = ""
        notificationCountLabel.text  = ""
//        notificationViewHeight.constant = 0
//        notificationViewWidth.constant = 0
//        self.layoutIfNeeded()
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(organisation: OrgLogin) {
//        if  name = organisation.org_name {
            nameLabel.text = organisation.org_name
//        }
//        if let imageString = organisation.logo_img {
        let imageString = organisation.logo_img
            if let imageUrl = URL(string: imageString) {
                thumbImageView.kf.setImage(with: imageUrl, placeholder: ImagePlaceholderView(), options: [.transition(.fade(0.2))])
//            }
        }
        let notificationCount = "0"//organisation.unreadCount
           
//        if((notificationCount!.count
//            > 0)&&(notificationCount != "0")){
//            notificationCountLabel.text = notificationCount
//            notificationViewHeight.constant = 18
//            notificationViewWidth.constant = 18
//        }
//        else{
            notificationViewHeight.constant = 0
            notificationViewWidth.constant = 0
//        }
        
    }
 
}
