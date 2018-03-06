//
//  TranslationsViewController.swift
//  XamarinLocalisor
//
//  Created by Mark Hoggatt on 01/03/2018.
//  Copyright © 2018 Mark Hoggatt. All rights reserved.
//

import Cocoa

class TranslationsViewController: NSViewController, NSMenuDelegate
{
	var fileUrl : URL?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		
		let openDialogue = NSOpenPanel()
		openDialogue.prompt = "Locate Xamarin solution"
		openDialogue.canChooseFiles = true
		openDialogue.canChooseDirectories = true
		let fileResponse : NSApplication.ModalResponse = openDialogue.runModal()
		if fileResponse == .continue
		{
			fileUrl = openDialogue.urls[0]
		}
    }
}
