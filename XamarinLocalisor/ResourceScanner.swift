//
//  ResourceScanner.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 01/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//

import Foundation

class ResourceScanner
{
	let solutionPattern : String = "*.sln"
	
	func ScanSolution(fileUrl : URL)
	{
	
	}
	
	func FindSolutionFile(filePath : URL) -> URL
	{
		return URL(fileReferenceLiteralResourceName: "")
	}
}
