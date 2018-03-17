//
//  LocalisableStringParser.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 17/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//

import Foundation

class LocalisableStringParser
{
	func decode(localisableStrings : String) -> [LangResource]
	{
		var langSet : [LangResource] = []

		let lineSet : [Substring] = localisableStrings.split(separator: "\n")
		var nextRes : LangResource?
		for resLine : Substring in lineSet
		{
			let linePart = String(trimStart(sample: resLine))
			if linePart.hasPrefix("//")
			{
				nextRes = LangResource(EntryIdentifier: "", TextEntry: "", EntryComment: trimComment(sample: linePart), TranslationDone: false, ShouldTranslate: true)
			}

			guard var workingRes : LangResource = nextRes
			else
			{
				continue
			}

			if trimStart(sample: resLine).hasPrefix("\"")
			{
				let lineParts = resLine.split(separator: "=")
				guard lineParts.count == 2
				else
				{
					continue
				}

				workingRes.EntryIdentifier = trimQuotes(sample: lineParts[0])
				workingRes.TextEntry = trimQuotes(sample: lineParts[1])
				langSet.append(workingRes)
			}
		}

		return langSet
	}

	fileprivate func trimStart(sample : Substring) -> String
	{
		let trimmed : Substring = sample.drop
		{(c : Character) -> Bool in
			return c == " "
		}

		return String(trimmed)
	}

	fileprivate func trimComment(sample : String) -> String
	{
		let trimmed : Substring = sample.drop
		{(c : Character) -> Bool in
			switch(c)
			{
			case "/", " ":
				return true

			default:
				return false
			}
		}

		return String(trimmed)
	}

	fileprivate func trimQuotes(sample : Substring) -> String
	{
		var quoteCount : Int = 0

		return String(sample.filter(
		{(c : Character) -> Bool in
			if c == "\""
			{
				quoteCount += 1
				return false
			}

			if quoteCount < 1
			{
				return false
			}

			if quoteCount > 1
			{
				return false
			}

			return true
		}))
	}
}
