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
	let solutionPath : String = "/Users/markho/Projects/AdminMobileApp"
	let iosResourcePath : String = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect/Resources"
	let androidResourcePath : String = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect.Droid/Resources"
	let iosStringResourcePath : String = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect/Resources/de.lproj"
	let iosStringLocalisable : String = "/Users/markho/Projects/AdminMobileApp/PaxtonConnect/Resources/de.lproj/Localizable.strings"
	let testRegion : String = "de"
	
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

	func testiOSResourceScan()
	{
		let iosResPath = URL(fileURLWithPath: iosResourcePath)
		var platfrmRsrce = PlatformResourceSet(IdentifiedPlatform: .iOS, ResourcePath: iosResPath, ResourceSet: [:])
		let rsrceGroups : [String : ResourceGroup] = workingScanner.AnalyseiOSResources(usingPlatformset: platfrmRsrce)
		platfrmRsrce.ResourceSet = rsrceGroups
		XCTAssertGreaterThan(rsrceGroups.count, 0)
	}

	func testFileListWithSuffix()
	{
		let iosResPath = URL(fileURLWithPath: iosStringResourcePath)
		let fileList : [URL] = workingScanner.FindFiles(filePath: iosResPath, withSuffix: "strings")
		XCTAssertGreaterThan(fileList.count, 0)
	}

	func testiOSLanguageFileScan()
	{
		let iosResPath = URL(fileURLWithPath: iosResourcePath)
		let rsrcGroup : ResourceGroup = workingScanner.ScaniOSLanguageFileSet(foundInUrl: iosResPath, regionId: testRegion)
		XCTAssertGreaterThan(rsrcGroup.LocalisationRegions.count, 0)
	}

	func testiOSResourseParse()
	{
		let iosResPath = URL(fileURLWithPath: iosStringLocalisable)
		let resources = workingScanner.ParseiOSLangFile(inLangFile: iosResPath)
		XCTAssertNotNil(resources)
	}

	func testLocalisedStringParse()
	{
		let iosResPath = URL(fileURLWithPath: iosStringLocalisable)
		do
		{
			let langResource = try String(contentsOf: iosResPath, encoding: String.Encoding.utf8)
			let parser = LocalisableStringParser()
			let langSet : [LangResource] = parser.decode(localisableStrings: langResource)
			XCTAssertGreaterThan(langSet.count, 0)
		}
		catch
		{
			NSLog("Failed to read resource file at \(iosResPath): \(error)")
			XCTFail()
		}
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
