//
//  InfoVewController.swift
//  LFSR_stream_cipher
//
//  Created by Egor Pii on 10/7/18.
//  Copyright © 2018 yenz0redd. All rights reserved.
//

import Cocoa

class InfoVewController: NSViewController {
    var nameFile : String = ""
    var inputFileSize = ""
    var outoutFileSize = ""
    var register = ""
    
    @IBOutlet weak var labelNameFile: NSTextField!
    @IBOutlet weak var labelInputFileSize: NSTextField!
    @IBOutlet weak var labelOutFileSize: NSTextField!
    @IBOutlet weak var labelRegister: NSTextField!

    override func viewDidLoad() {
        labelNameFile.stringValue = nameFile
        labelInputFileSize.stringValue = inputFileSize
        labelOutFileSize.stringValue = outoutFileSize
        labelRegister.stringValue = register
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
