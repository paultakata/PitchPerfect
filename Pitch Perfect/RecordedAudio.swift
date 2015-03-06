//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Paul Miller on 6/03/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    
    var filePathURL: NSURL?
    var title: String?
    
    //MARK: - Designated initialiser
    
    init(filePathURL: NSURL, title: String) {
        self.filePathURL = filePathURL
        self.title = title
        super.init()
    }
}