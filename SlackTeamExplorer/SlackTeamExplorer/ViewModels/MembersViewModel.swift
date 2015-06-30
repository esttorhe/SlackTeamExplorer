//
//  MembersViewModel.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import CoreData

// Pods
import ReactiveViewModel
import ReactiveCocoa
import ReachabilitySwift

public class MembersViewModel: RVMViewModel {
    private var members = [Member]()
    let beginLoadingSignal: RACSignal = RACSubject()
    let endLoadingSignal: RACSignal = RACSubject()
    let updateContentSignal: RACSignal = RACSubject()
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var numberOfSections: Int {
        get { return 1 }
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return self.members.count
    }
    
    func memberAtIndexPath(indexPath: NSIndexPath) -> Member {
        return self.members[indexPath.item]
    }
    
    override init() {
        super.init()
        
        reachability.startNotifier()
        self.didBecomeActiveSignal.subscribeNext { [unowned self] active in
            self.active = false
            // Notify caller that network request is about to begin
            if let beginSignal = self.beginLoadingSignal as? RACSubject { beginSignal.sendNext(nil) }
        
            if self.reachability.isReachable() {
                self.loadDataFromWeb()
            } else {
                self.loadDataFromDB()
            }
        }
    }
    
    // MARK: - Internal Helpers
    
    internal func loadDataFromWeb() {
        SlackProvider.request(.TeamUsersList) { (data, status, response, error) -> () in
            // Notify caller that network request ended
            if let endSignal = self.endLoadingSignal as? RACSubject { endSignal.sendNext(nil) }
            
            // Check if there was a network error, and if so notify back and cancel processing
            // data.
            if let err = error where err.code != 0 {
                if let updateSignal = self.updateContentSignal as? RACSubject {
                    updateSignal.sendError(err)
                }
                
                return
            }
            
            // Parse data
            if let data = data {
                var localError: NSError?
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &localError) {
                    if let members = json["members"] as? Array<Dictionary<NSObject, AnyObject>>,
                        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
                        context = appDelegate.managedObjectContext {
                            // Map the array of dictionaries into Member models removing possible `nil`s.
                            self.members = members.map { Member.memberInContext(context, json: $0) }.filter{ $0 != nil }.map{ $0! }
                            dispatch_async(dispatch_get_main_queue()) {
                                appDelegate.saveContext()
                            }
                            
                            // Report back the new data.
                            if let updateSignal = self.updateContentSignal as? RACSubject {
                                updateSignal.sendNext(self.members)
                            }
                    }
                } else {
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        updateSignal.sendError(localError)
                    }
                }
            }
        }
    }
    
    internal func loadDataFromDB() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            context = appDelegate.managedObjectContext {
                let fetch = NSFetchRequest(entityName: "Member")
                var innerError: NSError?
                if let currentMembers = context.executeFetchRequest(fetch, error: &innerError) as? Array<Member> {
                    // Notify caller that network request ended
                    if let endSignal = self.endLoadingSignal as? RACSubject { endSignal.sendNext(nil) }
                    
                    // Check if there was a network error, and if so notify back and cancel processing
                    // data.
                    if let err = innerError where err.code != 0 {
                        if let updateSignal = self.updateContentSignal as? RACSubject {
                            updateSignal.sendError(err)
                        }
                        
                        return
                    }
                    
                    self.members = currentMembers
                    
                    // Report back the new data.
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        updateSignal.sendNext(self.members)
                    }
                } else {
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        let err = NSError(domain: "es.estebantorr.SlackTeamExplorer.MembersViewModel",
                            code: -667,
                            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve `Member` models from the database"])
                        updateSignal.sendError(err)
                    }
                }
        }
    }
}
