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
	case NoResourcesFound
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
	let packageExclusion : String = "package"
	let resourceFolder : String = "Resources"

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

		var csprojDirs : [URL] = []
		for searchProj in solutionSubDirs
		{
			guard let projSet : URL = FindUrlInDirectory(filePath: searchProj, withSuffix: projectPattern)
			else
			{
				continue
			}

			csprojDirs.append(projSet.deletingLastPathComponent())
		}
		if csprojDirs.count <= 0
		{
			progressSet.append(.NoProjectsFound)
			return
		}

		// 3. Foreach directory with .csproj - Look for a directory called Resources
		progressSet.append(.ProjectFound)
		var resourcePaths : [URL] = []
		for projPath in csprojDirs
		{
			guard let rsrcPath = FindFolderInPath(filePath: projPath, withName: resourceFolder)
			else
			{
				continue
			}

			resourcePaths.append(rsrcPath)
		}
		if resourcePaths.count <= 0
		{
			progressSet.append(.NoResourcesFound)
			return
		}

		// 4. Foreach directory called Resources - If starts with values, then Android. If ends with lproj, then iOS.
		progressSet.append(.ResourcesFound)

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
				let fPath = pathRaw + "/" + fName
				let fUrl = URL(fileURLWithPath: fPath)
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
					dirSet.append(URL(fileURLWithPath: fullPath))
				}
			}
		}
		catch
		{
			NSLog("File enumderation failed: \(error.localizedDescription)")
		}

		return dirSet
	}


	/// Finds the directory path that matches the path to find string.
	///
	/// - Parameters:
	///   - filePath: The directory to search.
	///   - pathToFind: The sub-directory string to match.
	/// - Returns: The full path to the matching directory or nil if there is no match
	func FindFolderInPath(filePath: URL, withName pathToFind: String) -> URL?
	{
		let subDirs : [URL] = FindDirectoriesInDirectory(filePath: filePath)
		if subDirs.count <= 0
		{
			return nil
		}

		for dirPath in subDirs
		{
			if dirPath.lastPathComponent == pathToFind
			{
				return dirPath
			}
		}

		return nil
	}


	/// Examine the contents of the resource folder and identify its platform
	///
	/// - Parameter resourcePath: Path to the resource.
	/// - Returns: Classification of the resource type, include if it is not supported.
	func DiscoverResourceFolderPlatform(resourcePath: URL) -> ResourcePlatform
	{
		let iosSuffix : String = ".lproj"
		let androidPrefix = "values-"

		let resourceContents : [URL] = FindDirectoriesInDirectory(filePath: resourcePath)
		guard resourceContents.count > 0
		else
		{
			return .Unsupported
		}

		var workingType : ResourcePlatform = .Unsupported
		for rFolder in resourceContents
		{
			if rFolder.lastPathComponent.hasSuffix(iosSuffix)
			{
				if workingType != .Android
				{
					workingType = .iOS
				}
				else
				{
					NSLog("Ambiguous resource file set - Expecting IOS")
				}
			}

			if rFolder.lastPathComponent.hasPrefix(androidPrefix)
			{
				if workingType != .iOS
				{
					workingType = .Android
				}
				else
				{
					NSLog("Ambiguous resource file set - Expecting Android")
				}
			}
		}

		return workingType
	}
}
