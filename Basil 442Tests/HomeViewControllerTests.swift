//
//  HomeViewControllerTests.swift
//  Basil 442
//
//  Created by Sophie Zhao on 12/14/16.
//  Copyright © 2016 team danko_. All rights reserved.
//

import XCTest
@testable import Basil_442


class HomeViewControllerTests: XCTestCase {
    
    var testVC: HomeViewController! = HomeViewController()
    
    override func setUp() {
        super.setUp()
        self.testVC = HomeViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization(){
        //Test values start off as nil
        XCTAssertEqual(self.testVC.rnd.isEmpty, true)
    }
    
    
    
}
