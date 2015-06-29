//
//  ViewController.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    /// Will hold the member used to seed the UI
    var member: Member?
    
    required init(coder aDecoder: NSCoder) {
        self.member = nil
        
        super.init(coder: aDecoder)
    }
    
    // IB variables
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var skypeLabel: UILabel!
    
    override func viewWillLayoutSubviews() {
        self.configureAvatarImageView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI
        self.configureAvatarImageView()
        
        // Check if there's a valid member
        if let member = self.member {
            usernameLabel.text = "@\(member.name)"
            self.title = member.name
            
            // Unwrap the profile
            if let profile = member.profile {
                if let realname = profile.realNameNormalized {
                    fullNameLabel.text = realname
                }
                
                if let title = profile.title {
                    titleLabel.text = title
                }
                
                if let imageURL = profile.image192, url = NSURL(string: imageURL) {
                    avatarImageView.sd_setImageWithURL(url, placeholderImage: nil) { (image, error, cacheType, url) in
                        if let img = image {
                            self.avatarImageView.image = img
                        } else if let fburl = profile.fallBackImageURL {
                            self.avatarImageView.sd_setImageWithURL(fburl)
                        }
                    }
                }
                
                if let phone = profile.phone {
                    phoneLabel.text = "☎ \(phone)"
                }
                
                if let email = profile.email {
                    emailLabel.text = "✉ \(email)"
                }
                
                if let skype = profile.skype {
                    skypeLabel.text = "💻 \(skype)"
                }
            }
        }
    }
    
    // MARK: - Internal UI Helpers
    
    internal func configureAvatarImageView(duration:NSTimeInterval = 0.5) {
        self.avatarImageView.layoutIfNeeded()
        UIView.animateWithDuration(duration) {
            self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.bounds) / 2.0
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.layer.borderColor = UIColor.slackLightGreyColor().CGColor
            self.avatarImageView.layer.borderWidth = 2.0
        }
    }
}