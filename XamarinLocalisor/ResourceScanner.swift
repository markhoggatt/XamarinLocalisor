//
//  ResourceScanner.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 01/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//

import Foundation

enum ScanProgress
{
	case NoSolutionFound
	case SolutionFound
	case NoProjectsFound
	case ProjectFound
	case ResourcesFound
	case AndroidResources
	case iOSResources
	case ExtractedAndroidSources
	case ExtractediOSSources
}

class ResourceScanner
{
	let solutionPattern : String = "sln"
	let projectPattern : String = "csproj"
	var progressSet : [ScanProgress] = [ScanProgress]()
	
	func ScanSolution(fileUrl : URL)
	{
		// 1. Look for .sln file
		let soltionUrl : URL? = FindUrlInDirectory(filePath: fileUrl, withSuffix: solutionPattern)
		guard soltionUrl != nil
		else
		{
			progressSet.append(.NoSolutionFound)
			return
		}

		progressSet.append(.SolutionFound)
		// 2. Foreach directory - Excluding packages - look for .csproj file
		let solutionSubDirs : [URL] = FindDirectoriesInDirectory(filePath: fileUrl)
		guard solutionSubDirs.isEmpty == false
		else
		{
			progressSet.append(.NoProjectsFound)
			return
		}

		// 3. Foreach directory with .csproj - Look for a directory called Resources

		// 4. Foreach directory called Resources - If starts with values, then Android. If ends with lproj, then iOS.

		// 5. Extract Platform, Language, Key, Text, Comment
	}


	/// Locates the first path in a direct which is a path of the given suffix.
	///
	/// - Parameters:
	///   - filePath: The path to search for the suffix.
	///   - suffix: The suffix to search.
	/// - Returns: The URL of the file or nil if the file suffix was not found.
	func FindUrlInDirectory(filePath : URL, withSuffix suffix : String) -> URL?
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
			let fileSet : [String] = try fMgr.contentsOfDirectory(atPath: pathRaw)
			for fName in fileSet
			{
				let fUrl = URL(fileURLWithPath: fName)
				if fUrl.pathExtension == suffix
				{
					return fUrl
				}
			}
		}
		catch
		{
			NSLog("File enumderation failed: \(error.localizedDescription)")
		}

		return nil
	}


	/// Finds a list of URLS within a path that are themselves directories.
	///
	/// - Parameter filePath: The path to search.
	/// - Returns: An array of URL's that are directories. This is empty if none was found.
	func FindDirectoriesInDirectory(filePath : URL) -> [URL]
	{
		var dirSet : [URL] = [URL]()
		let fMgr : FileManager = FileManager.default

		let pathRaw : String = filePath.path

		guard fMgr.fileExists(atPath: pathRaw)
		else
		{
			return dirSet
		}

		do
		{
			let fileSet : [String] = try fMgr.contentsOfDirectory(atPath: pathRaw)
			for fName in fileSet
			{
				let fullPath : String = pathRaw + "/" + fName
				var isDirectory : ObjCBool = false
				let fileExists : Bool = fMgr.fileExists(atPath: fullPath, isDirectory: &isDirectory)
				if fileExists && isDirectory.boolValue
				{
					dirSet.append(URL(fileURLWithPath: fName))
				}
			}
		}
		catch
		{
			NSLog("File enumderation failed: \(error.localizedDescription)")
		}

		return dirSet
	}
}
