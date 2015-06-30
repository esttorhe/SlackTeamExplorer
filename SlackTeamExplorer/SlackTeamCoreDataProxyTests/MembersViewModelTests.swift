//
//  MembersViewModelTest.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 30/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import XCTest
import CoreData
import Foundation

// Framework to be tested
import SlackTeamCoreDataProxy

// Pods
import OHHTTPStubs
import ReactiveCocoa

class MembersViewModelTests: XCTestCase {
    var updateRACDisposable: RACDisposable?=nil
    lazy var coreDataProxy: SlackTeamCoreDataProxy = { SlackTeamCoreDataProxy() }()
    
    override func setUp() {
        super.setUp()
        coreDataProxy.useMemoryStorage = true
        
        OHHTTPStubs.stubRequestsPassingTest({ request -> Bool in
            if let url = request.URL
            where request.HTTPMethod == "GET" {
                if let host = url.host,
                    absoluteString = url.absoluteString
                where host == "slack.com" {
                    return absoluteString.rangeOfString("users.list") != nil
                }
            }

            return false
        }, withStubResponse: { request -> OHHTTPStubsResponse in
            let filePath = OHPathForFile("members.json", MemberTests.self)!
            
            return OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: ["Content-Type":"application/json"])
        })
    }
    
    override func tearDown() {
        super.tearDown()
        if let updateRD = self.updateRACDisposable {
            updateRD.dispose()
        }
    }
    
    func testMembersViewModelUpdateContentSignal() {
        var expectation = self.expectationWithDescription("MembersViewModel returned data.")
        let membersVM = MembersViewModel(useGroupContext: false)
        
        self.updateRACDisposable = membersVM.updateContentSignal.deliverOnMainThread().subscribeNext { membs in
            XCTAssertNotNil(membs, "Unable to retrieve members from a JSON request.")
            XCTAssertGreaterThan(membs.count, 0, "Parsed members response is empty.")
            
            if let members = membs as? Array<Member> {
                XCTAssertEqual(members.count, membs.count, "Returned `Member` array is different than the JSON provided.")
                XCTAssertEqual(members.count, membersVM.numberOfItemsInSection(0), "Returned `Member` array is different than the parsed response.")
                
                if let member = members.first,
                indexPath = NSIndexPath(forItem: 0, inSection: 0) {
                    XCTAssertEqual(member, membersVM.memberAtIndexPath(indexPath), "`Member` at index 0 doesn't match parsed `Member` at index 0.")
                }
            }
            
            if let disposable = self.updateRACDisposable { disposable.dispose(); self.updateRACDisposable = nil }
            expectation.fulfill()
        }
        membersVM.active = true
        
        self.waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    
    func testMembersViewModelUpdateContentSignalDBFallback() {
        var expectation = self.expectationWithDescription("MembersViewModel returned data.")
        let membersVM = MembersViewModel(useGroupContext: false)
        
        self.updateRACDisposable = membersVM.updateContentSignal.deliverOnMainThread().subscribeNext { membs in
            XCTAssertNotNil(membs, "Unable to retrieve members from a JSON request.")
            XCTAssertGreaterThan(membs.count, 0, "Parsed members response is empty.")
            
            if let members = membs as? Array<Member> {
                XCTAssertEqual(members.count, membs.count, "Returned `Member` array is different than the JSON provided.")
                XCTAssertEqual(members.count, membersVM.numberOfItemsInSection(0), "Returned `Member` array is different than the parsed response.")
                
                if let member = members.first,
                    indexPath = NSIndexPath(forItem: 0, inSection: 0) {
                        XCTAssertEqual(member, membersVM.memberAtIndexPath(indexPath), "`Member` at index 0 doesn't match parsed `Member` at index 0.")
                }
            }
            
            if let disposable = self.updateRACDisposable { disposable.dispose(); self.updateRACDisposable = nil }
            membersVM.loadFromDBOnly = true
            
            self.updateRACDisposable = membersVM.updateContentSignal.deliverOnMainThread().subscribeNext { membs in
                XCTAssertNotNil(membs, "Unable to retrieve members from a JSON request.")
                XCTAssertGreaterThan(membs.count, 0, "Parsed members response is empty.")
                
                if let members = membs as? Array<Member> {
                    XCTAssertEqual(members.count, membs.count, "Returned `Member` array is different than the JSON provided.")
                    XCTAssertEqual(members.count, membersVM.numberOfItemsInSection(0), "Returned `Member` array is different than the parsed response.")
                    
                    if let member = members.first,
                        indexPath = NSIndexPath(forItem: 0, inSection: 0) {
                            XCTAssertEqual(member, membersVM.memberAtIndexPath(indexPath), "`Member` at index 0 doesn't match parsed `Member` at index 0.")
                    }
                }
                
                if let disposable = self.updateRACDisposable { disposable.dispose(); self.updateRACDisposable = nil }
                expectation.fulfill()
            }
            membersVM.active = true
        }
        membersVM.active = true
        
        self.waitForExpectationsWithTimeout(15.0, handler: nil)
    }
}