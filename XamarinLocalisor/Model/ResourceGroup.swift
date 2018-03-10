//
//  ResourceGroup.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 10/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//
import Foundation

/// Identifies the platform to which the resource belongs.
/// - Unsupported: This is a resource not identified as belonging to a supported platform
/// - iOS: This is a resource belonging to an iOS project
/// - Android: This is a resource belonging to an Android project
enum ResourcePlatform
{
	case Unsupported
	case iOS
	case Android
}


/// A group that contains a set of resources for a given platform and set of regions.
struct ResourceGroup
{
	/// The plat that contains the resurce.
	var Classification : ResourcePlatform

	/// The region identifier culled from the file name.
	var RegionId : String

	/// Dictionary of resource entry dictionaries. Key=region, Value = Array of Lang resources.
	var LocalisationRegions : [String : [LangResource]]

	/// Path to locate the resource group
	var OriginatingPath : URL
}
