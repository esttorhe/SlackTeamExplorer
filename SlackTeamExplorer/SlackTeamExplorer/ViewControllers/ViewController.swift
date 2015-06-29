//
//  ViewController.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

import UIKit
import HexColors
import SDWebImage

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // ViewModels
    internal let membersViewModel = MembersViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view models
        membersViewModel.beginLoadingSignal.deliverOnMainThread().subscribeNext { [unowned self] _ in
            self.loadingActivityIndicator.startAnimating()
        }
        
        membersViewModel.endLoadingSignal.deliverOnMainThread().subscribeNext { [unowned self] _ in
            self.loadingActivityIndicator.stopAnimating()
        }
        
        membersViewModel.updateContentSignal.deliverOnMainThread().subscribeNext({ [unowned self] members in
            self.collectionView.reloadData()
            }, error: { error in
                // TODO: Show error to the user
                println("• Unable to load members: \(error)")
        })
        
        // Trigger first load
        membersViewModel.active = true
    }
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.membersViewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemberCell", forIndexPath: indexPath) as! MemberCell
        cell.avatarImageView.image = nil
        cell.avatarImageView.backgroundColor = UIColor.slackPurpleColor()
        cell.usernameLabel.text = nil
        cell.titleLabel.text = nil
        
        let member = membersViewModel.memberAtIndexPath(indexPath)
        cell.usernameLabel.text = "@\(member.name)"
        
        if let profile = member.profile {
            if let imageURL = profile.image192 {
                cell.avatarImageView.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: nil) { (image, error, cacheType, url) in
                    if let img = image {
                        cell.avatarImageView.image = img
                    } else {
                        // SDWebImage sometimes fails to render the Gravatar URL
                        // hence we need to extract the underlying URL in order to use it.
                        // Gravatar URL ->
                        // e.g.: https://secure.gravatar.com/avatar/bbbca62a1ddf20311d32c1bd5bcc5d90.jpg?s=192&d=https://slack.global.ssl.fastly.net/3654/img/avatars/ava_0003.png
                        if let urlComp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), items = urlComp.queryItems as? [NSURLQueryItem], urlStr = (items.filter { element -> Bool in
                            return element.name == "d" // Only filter the «d» query parameter
                            }.map { $0.value }.first), realStr = urlStr {
                                cell.avatarImageView.sd_setImageWithURL(NSURL(string: realStr)!) // We successfully unwrapped the url from the «d» query parameter
                        }
                    }
                }
            }
            
            if let title = profile.title {
                cell.titleLabel.text = title
            }
        }
        
        if let strColor = member.color, color = UIColor(hexString: strColor) {
            cell.avatarImageView.layer.borderWidth = 4.0
            cell.avatarImageView.layer.borderColor = color.CGColor
            
            cell.layer.cornerRadius = 10.0
        }
        
        return cell
    }
    
    // MARK: - Collection View Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 30.0, 81.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
}