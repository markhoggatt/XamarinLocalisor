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
	
	func FindSolutionFile(filePath : URL) -> URL?
	{
		let fMgr : FileManager = FileManager.default

		let pathRaw : String = filePath.path

		guard fMgr.fileExists(atPath: pathRaw)
		else
		{
			return nil
		}

		do
		{
			let fileSet = try fMgr.contentsOfDirectory(atPath: pathRaw)
			for fName in fileSet
			{
				let fUrl = URL(fileURLWithPath: fName)
				if fUrl.pathExtension == "sln"
				{
					return fUrl
				}
			}
		}
		catch
		{
			NSLog("File enumderation failed: \(error.localizedDescription)")
			return nil
		}

		return nil
	}
}
