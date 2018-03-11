//
//  PlatformResouceSet.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 11/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//
import Foundation


/// Top level container of resources for a given platform
struct PlatformResourceSet
{
	/// Platform containing the resources
	var IdentifiedPlatform : ResourcePlatform

	/// Location for the resources folder
	var ResourcePath : URL

	/// Contains the resource set for each region. Key = Region Id, Value = Resource group set for that region
	var ResourceSet : [String : ResourceGroup]
}
