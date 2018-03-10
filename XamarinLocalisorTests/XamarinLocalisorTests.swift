//
//  XamarinLocalisorTests.swift
//  XamarinLocalisorTests
//
//  Created by Mark Hoggatt on 01/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//

import XCTest
@testable import XamarinLocalisor

class XamarinLocalisorTests: XCTestCase
{
	let solutionPath = "/Users/markho/Projects/AdminMobileApp"
	let iosResourcePath = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect/Resources"
	let androidResourcePath = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect.Droid/Resources"
	
	let workingScanner : ResourceScanner = ResourceScanner()
	
    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSolutionExists()
	{
		let solutionUrl = URL(fileURLWithPath: solutionPath)
		let foundSolution : URL? = workingScanner.FindUrlInDirectory(filePath: solutionUrl, withSuffix : "sln")
		XCTAssertNotNil(foundSolution)
    }

	func testDirectoryContainment()
	{
		let solutionUrl = URL(fileURLWithPath: solutionPath)
		let foundDirectories : [URL] = workingScanner.FindDirectoriesInDirectory(filePath: solutionUrl)
		XCTAssertFalse(foundDirectories.isEmpty)
	}

	func testScanSolution()
	{
		let solutionUrl = URL(fileURLWithPath: solutionPath)
		workingScanner.ScanSolution(fileUrl: solutionUrl)
	}

	func testIosResourceDetection()
	{
		let iosResourcePlatform = URL(fileURLWithPath: iosResourcePath)
		let resourcePlatform : ResourcePlatform = workingScanner.DiscoverResourceFolderPlatform(resourcePath: iosResourcePlatform)
		XCTAssertEqual(ResourcePlatform.iOS, resourcePlatform)
	}

	func testAndroidResourceDetection()
	{
		let androidResourcePlatform = URL(fileURLWithPath: androidResourcePath)
		let resourcePlatform : ResourcePlatform = workingScanner.DiscoverResourceFolderPlatform(resourcePath: androidResourcePlatform)
		XCTAssertEqual(ResourcePlatform.Android, resourcePlatform)
	}
    
    func testPerformanceExample()
	{
        // This is an example of a performance test case.
        self.measure
		{
            // Put the code you want to measure the time of here.
        }
    }
}
