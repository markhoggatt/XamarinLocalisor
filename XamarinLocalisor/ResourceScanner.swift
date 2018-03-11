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
	case UnsupportedResources
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

		// We only want to process resources if there are any.
		guard resourcePaths.count > 0
		else
		{
			progressSet.append(.NoResourcesFound)
			return
		}

		// 4. Foreach directory called Resources - If starts with values, then Android. If ends with lproj, then iOS.
		var platformRes : [PlatformResourceSet] = []
		progressSet.append(.ResourcesFound)
		for rPath : URL in resourcePaths
		{
			let rsrceType : ResourcePlatform = DiscoverResourceFolderPlatform(resourcePath: rPath)
			guard rsrceType != .Unsupported
			else
			{
				continue
			}

			let foundRsrc = PlatformResourceSet(IdentifiedPlatform: rsrceType, ResourcePath: rPath, ResourceSet: [:])
			platformRes.append(foundRsrc)
		}

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

	/// Returns the list of files with the matching suffix.
	///
	/// - Parameters:
	///   - filePath: The path to search for the suffix.
	///   - suffix: The suffix to search.
	/// - Returns: The URL of the file or nil if the file suffix was not found.
	func FindFiles(filePath : URL, withSuffix suffix : String) -> [URL]
	{
		let fMgr : FileManager = FileManager.default

		let pathRaw : String = filePath.path

		guard fMgr.fileExists(atPath: pathRaw)
			else
		{
			return []
		}

		var fileList : [URL] = []
		do
		{
			let fileSet : [String] = try fMgr.contentsOfDirectory(atPath: pathRaw)
			for fName in fileSet
			{
				let fPath = pathRaw + "/" + fName
				let fUrl = URL(fileURLWithPath: fPath)
				if fUrl.pathExtension == suffix
				{
					fileList.append(fUrl)
				}
			}

			return fileList
		}
		catch
		{
			NSLog("File enumderation failed: \(error.localizedDescription)")
		}

		return []
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

		var progessResult : ScanProgress = .UnsupportedResources
		switch workingType
		{
		case .Android:
			progessResult = .AndroidResources
		case .iOS:
			progessResult = .iOSResources
		default:
			NSLog("Ambiguous or unexpected resource discovery scan")
		}

		progressSet.append(progessResult)

		return workingType
	}

	func AnalyseiOSResources(usingPlatformset rsrcSet: PlatformResourceSet) -> [String : ResourceGroup]
	{
		guard rsrcSet.IdentifiedPlatform == .iOS
		else
		{
			NSLog("Incorrect analysis call - Expecting iOS, found \(rsrcSet.IdentifiedPlatform)")
			return [:]
		}

		let regionSet : [URL] = FindDirectoriesInDirectory(filePath: rsrcSet.ResourcePath)
		var rsrcGroup : [String : ResourceGroup] = [:]
		for regionDir : URL in regionSet
		{
			let regionResource : String = regionDir.lastPathComponent
			let regionTag : String = String(regionResource.prefix(while:
			{ (c : Character) -> Bool in
				return c != "."
			}))

			guard regionTag.count > 0
			else
			{
				continue
			}

			let rGroup = ScaniOSLanguageFileSet(foundInUrl: rsrcSet.ResourcePath, regionId: regionTag)
			if rsrcSet.ResourceSet.contains(where:
				{ (key : String, value : ResourceGroup) -> Bool in
					return key == regionTag
				})
			{
				NSLog("Possible duplication of region: \(regionTag)")
				continue
			}

			rsrcGroup[regionTag] = rGroup
		}

		return rsrcGroup
	}

	func ScaniOSLanguageFileSet(foundInUrl rsrceUrl : URL, regionId : String) -> ResourceGroup
	{
		var regionGroup = ResourceGroup(RegionId: regionId, LocalisationRegions: [:])
		let regionSuffix : String = regionId + ".lproj"
		var regionPath : URL = rsrceUrl
		regionPath.appendPathComponent(regionSuffix)
		let langFiles : [URL] = FindFiles(filePath: regionPath, withSuffix: "strings")
		guard langFiles.count > 0
		else
		{
			return regionGroup
		}

		var langEntries : [LangResource] = []
		for langFile : URL in langFiles
		{
			let entrySet : [LangResource] = ParseiOSLangFile(inLangFile: langFile)
			guard entrySet.count > 0
			else
			{
				continue
			}

			langEntries.append(contentsOf: entrySet)
		}

		regionGroup.LocalisationRegions[regionId] = langEntries

		return regionGroup
	}

	func ParseiOSLangFile(inLangFile langFile : URL) -> [LangResource]
	{
		var langSet : [LangResource] = []

		let fMgr : FileManager = FileManager.default

		do
		{
			let langResource = try String(contentsOf: langFile, encoding: String.Encoding.utf8)
		}
		catch
		{
			NSLog("Failed to read resource file at \(langFile): \(error)")
		}

		return langSet
	}
}
