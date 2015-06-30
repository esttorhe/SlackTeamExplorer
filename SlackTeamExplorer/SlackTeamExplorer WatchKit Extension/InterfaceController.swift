//
//  InterfaceController.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import CoreData
import WatchKit

// Chared Code
import SlackTeamCoreDataProxy

// Pods
import ReactiveViewModel
import ReactiveCocoa
import ReachabilitySwift
import HexColors

public struct ImageLoader {
    internal class ImageOperation: NSOperation {
        var image_url: String!
        var image: UIImage!
        
        override func main() {
            if let imageURL = self.image_url, let url:NSURL = NSURL(string:imageURL),
                data:NSData = NSData(contentsOfURL: url), image = UIImage(data: data) {
                    self.image = image
            }
        }
    }
    
    internal class ImageQueue {
        lazy var queue: NSOperationQueue = {
            let queue = NSOperationQueue()
            queue.qualityOfService = .Background
            queue.maxConcurrentOperationCount = 1
            
            return queue
        }()
    }
    
    static var imageQueue = ImageQueue()
    
    static func loadImage(url:String, forImageView: WKInterfaceImage) {
        // load image
        let imageOp = ImageOperation()
        imageOp.image_url = url
        imageOp.completionBlock = {
            dispatch_async(dispatch_get_main_queue()) {
                [unowned forImageView] in
                if let image = imageOp.image {
                    forImageView.setImage(image)
                }
            }
        }
        
        ImageLoader.imageQueue.queue.addOperation(imageOp)
    }
    
    static func stopLoadingImage() {
        ImageLoader.imageQueue.queue.cancelAllOperations()
    }
}
    
class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var warningGroup: WKInterfaceGroup!
    let membersViewModel = MembersViewModel()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
        self.membersViewModel.loadFromDBOnly = true
        self.membersViewModel.updateContentSignal.deliverOnMainThread().subscribeNext { membs in
            if let members = membs as? [Member]
            where members.count > 0 {
                self.table.setHidden(false)
                self.warningGroup.setHidden(true)
                
                self.table.setNumberOfRows(members.count, withRowType: "RowTableRowController")
                for (index, member) in enumerate(members) {
                    let row = self.table.rowControllerAtIndex(index) as! RowTableRowController
                    row.label.setText(member.name)
                    
                    if let strColor = member.color,
                        color = UIColor(hexString: strColor) {
                            row.label.setTextColor(color)
                    }
                }
            } else {
                self.table.setHidden(true)
                self.warningGroup.setHidden(false)
            }
        }
        
        self.membersViewModel.active = true
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return self.membersViewModel.memberAtIndexPath(NSIndexPath(forItem: rowIndex, inSection: 0)).objectID
    }
}
