//
//  MemberViewModel.swift
//  SlackTeamCoreDataProxy
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import CoreData

// Shared Code
import SlackTeamCoreDataProxy

// Pods
import ReactiveViewModel
import ReactiveCocoa
import ReachabilitySwift

public class MemberViewModel: RVMViewModel {
    private var memberID: NSManagedObjectID?
    private(set) var member: Member?=nil
    public let beginLoadingSignal: RACSignal = RACSubject()
    public let endLoadingSignal: RACSignal = RACSubject()
    public let updateContentSignal: RACSignal = RACSubject()
    public let reachability = Reachability.reachabilityForInternetConnection()
    
    public init(memberID: NSManagedObjectID) {
        self.memberID = memberID
        super.init()
        
        self.didBecomeActiveSignal.subscribeNext { [unowned self] _ in
            self.active = false
            
            // Notify caller that network request is about to begin
            if let beginSignal = self.beginLoadingSignal as? RACSubject { beginSignal.sendNext(nil) }
            
            let coreDataProxy = SlackTeamCoreDataProxy()
            
            if let objectID = self.memberID,
                context = coreDataProxy.managedObjectContext {
                    var error: NSError?
                    if let member = context.existingObjectWithID(objectID, error: &error) as? Member {
                        self.member = member
                        
                        // Notify caller that network request ended
                        if let updateSignal = self.updateContentSignal as? RACSubject { updateSignal.sendNext(member) }
                    }
            }
            
            // Notify caller that network request ended
            if let endSignal = self.endLoadingSignal as? RACSubject { endSignal.sendNext(nil) }
        }
    }
}