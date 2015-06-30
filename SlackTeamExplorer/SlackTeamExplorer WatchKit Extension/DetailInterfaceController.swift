//
//  DetailInterfaceController.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import WatchKit
import Foundation
import CoreData

// Shared Code
import SlackTeamCoreDataProxy

// Pods
import ReactiveCocoa
import HexColors

class DetailInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var usernameLabel: WKInterfaceLabel!
    @IBOutlet weak var realNameLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var avatarImageView: WKInterfaceImage!
    private var updateRACDisposable: RACDisposable? = nil
    private var memberViewModel: MemberViewModel? = nil
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let memberID = context as? NSManagedObjectID {
            self.memberViewModel = MemberViewModel(memberID: memberID)
            updateRACDisposable = self.memberViewModel?.updateContentSignal.deliverOnMainThread().subscribeNext { memb in
                if let member = memb as? Member, profile = member.profile {
                    self.usernameLabel.setText("@\(member.name)")
                    self.titleLabel.setText(member.name)
                    
                    if let realName = profile.realName {
                        self.realNameLabel.setText(realName)
                    }
                    
                    if let title = profile.title {
                        self.titleLabel.setText(title)
                    }
                    
                    if let imageURL = profile.image192 {
                        ImageLoader.loadImage(imageURL, forImageView: self.avatarImageView)
                    }
                    
                    if let strColor = member.color,
                        color = UIColor(hexString: strColor) {
                            self.usernameLabel.setTextColor(color)
                            self.realNameLabel.setTextColor(color)
                            self.titleLabel.setTextColor(color)
                    }
                }
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if let memberViewModel = self.memberViewModel {
            memberViewModel.active = true
        }
    }
    
    override func didDeactivate() {
        if let disposable = self.updateRACDisposable {
            disposable.dispose()
        }
        
        ImageLoader.stopLoadingImage()
    }
}
