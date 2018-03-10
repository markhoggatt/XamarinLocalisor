//
//  LangResource.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 10/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//


/// Language resource detail
struct LangResource
{
	/// Entry key as used within the resource file to identify the translatable entry.
	var EntryIdentifier : String

	/// The translatable entry
	var TextEntry : String

	/// Programmer's comment
	var EntryComment : String

	/// Indicates whether or not the translation has been carried out
	var TranslationDone : Bool

	/// Indicates whether or not a new translation is required.
	var ShouldTranslate : Bool
}
