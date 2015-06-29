//
//  MemberCell.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

import UIKit

class MemberCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 10.0
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}