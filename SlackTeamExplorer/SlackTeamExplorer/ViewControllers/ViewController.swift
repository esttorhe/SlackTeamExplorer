//
//  ViewController.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import UIKit

// Shared
import SlackTeamCoreDataProxy

// Misc.
import HexColors

// Network
import SDWebImage

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // ViewModels
    let membersViewModel = MembersViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure transparent nav bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        // Configure the view models
        membersViewModel.beginLoadingSignal.deliverOnMainThread().subscribeNext { [unowned self] _ in
            self.loadingActivityIndicator.startAnimating()
        }
        
        membersViewModel.endLoadingSignal.deliverOnMainThread().subscribeNext { [unowned self] _ in
            self.loadingActivityIndicator.stopAnimating()
        }
        
        membersViewModel.updateContentSignal.deliverOnMainThread().subscribeNext({ [unowned self] members in
            self.collectionView.reloadData()
            }, error: { [unowned self] error in
                let alertController = UIAlertController(title: "Unable to fetch members", message: error?.description, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                println("• Unable to load members: \(error)")
        })
        
        // Trigger first load
        membersViewModel.active = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController,
            cell = sender as? MemberCell,
            indexPath = collectionView.indexPathForCell(cell) {
                let member = membersViewModel.memberAtIndexPath(indexPath)
                detailVC.memberViewModel = MemberViewModel(memberID: member.objectID)
        }
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
                    } else if let fburl = profile.fallBackImageURL {
                        cell.avatarImageView.sd_setImageWithURL(fburl)
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
    
    override func didRotateFromInterfaceOrientation(_: UIInterfaceOrientation) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Collection View Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        collectionView.layoutIfNeeded()
        return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 30.0, 81.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
}