//
//  Models.swift
//  Mobile Voice Memo Organizer
//
//  Created by Alaska Day on 5/3/20.
//  Copyright © 2020 Alaska Day. All rights reserved.
//

import Foundation

struct Folder {
    var name = ""
    var recordingList = [Recording]()
}

struct Recording {
    // User input
    var name = ""
    // Representation of the name of the file in the directory ("1.m4a")
    //this is how we can access the recordings
    var fileName = ""
    var transcription = ""
}





