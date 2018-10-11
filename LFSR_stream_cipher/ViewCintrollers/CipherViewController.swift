//
//  CipherViewController.swift
//  LFSR_stream_cipher
//
//  Created by Egor Pii on 10/7/18.
//  Copyright © 2018 yenz0redd. All rights reserved.
//

import Cocoa

fileprivate extension String {
    subscript(i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
}

class CipherViewController: NSViewController {

    var arrInputBytes = [UInt8]()
    var keyArr = [UInt8]()
    var resArr = [UInt8]()
    var nameFile = ""
    var inputFileSize = ""
    var outputFileSize = ""
    var globalRegister = ""

    @IBOutlet weak var textFieldInputBytes: NSTextField!
    @IBOutlet weak var textFieldRegister: NSSecureTextField!
    @IBOutlet weak var textFieldKey: NSTextField!
    @IBOutlet weak var textFieldOutputBytes: NSTextField!
    @IBOutlet weak var labelInputFileSize: NSTextField!
    @IBOutlet weak var labelKeySize: NSTextField!
    @IBOutlet weak var labelOutputFileSize: NSTextField!
    @IBOutlet weak var prbarDowload: NSProgressIndicator!
    @IBOutlet weak var prbarCipher: NSProgressIndicator!
    @IBOutlet weak var prbarUpload: NSProgressIndicator!
    @IBOutlet weak var textFieldIndexCheckByte: NSTextField!
    @IBOutlet weak var labelCheckByte1: NSTextField!
    @IBOutlet weak var labelCheckerByte2: NSTextField!
    @IBOutlet weak var labelCheckerByte3: NSTextField!
    @IBOutlet weak var prbarAllProcess: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()

        prbarUpload.doubleValue = 0
        prbarDowload.doubleValue = 0
        prbarCipher.doubleValue = 0
        prbarAllProcess.doubleValue = 0

        textFieldInputBytes.stringValue = ""
        textFieldOutputBytes.stringValue = ""
        textFieldKey.stringValue = ""

        labelKeySize.stringValue = "0"
        labelInputFileSize.stringValue = "0"
        labelOutputFileSize.stringValue = "0"

        labelCheckByte1.stringValue = "0000 0000"
        labelCheckerByte2.stringValue = "0000 0000"
        labelCheckerByte3.stringValue = "0000 0000"

        arrInputBytes = []
        resArr = []
        keyArr = []

        // Do view setup here.
    }

    @IBAction func btnGenerateAction(_ sender: NSButton) {

    }

    @IBAction func saveFileEncrypted(_ sender: Any) {
        prbarUpload.increment(by: 100)
        prbarAllProcess.increment(by: 33.33)

        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a .txt file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        //dialog.allowedFileTypes        = ["txt", ""]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let fileURL = dialog.url

            if fileURL != nil {
                let outputStream = OutputStream(toFileAtPath: fileURL!.path, append: false)!
                    outputStream.open()
                    outputStream.write(resArr, maxLength: resArr.count)
                    outputStream.close()
            }
        }
    }

    @IBAction func LoadFileAction(_ sender: NSButton) {
            viewDidLoad()

            let dialog = NSOpenPanel();

            dialog.title                   = "Choose a .txt file"
            dialog.showsResizeIndicator    = true
            dialog.showsHiddenFiles        = false
            dialog.canChooseDirectories    = false
            dialog.canCreateDirectories    = false
            dialog.allowsMultipleSelection = false
            //dialog.allowedFileTypes        = ["txt", "pages", "jpg", "mp3"]

            if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                let result = dialog.url
                nameFile = result!.path

                if (result != nil) {

                    if let data = NSData(contentsOfFile: result!.path) {

                        var buffer = [UInt8](repeating: 0, count: data.length)
                        data.getBytes(&buffer, length: data.length)
                        arrInputBytes = buffer
                    }

                    if arrInputBytes.count == 0 {
                        dialogAlert(message: "Empty File!")
                        return
                    }

                    inputByteFields(inputArr: arrInputBytes, field: textFieldInputBytes)

                    textFieldInputBytes.stringValue.append("\n")

                    labelInputFileSize.stringValue = String(arrInputBytes.count)

                    prbarDowload.increment(by: 100)
                    prbarAllProcess.increment(by: 33.34)

                    textFieldOutputBytes.stringValue = ""
                    textFieldKey.stringValue = ""

                }
            } else {
                dialogAlert(message: "Incorrect File!")
                return
            }
        }

    @IBAction func BtnCipherAction(_ sender: NSButton) {

        prbarCipher.maxValue = Double(arrInputBytes.count)

        func takeNewBitRegister(_ num : inout Int32) {
            var numOnes : Int32 = 0
            for index in [1, 3, 4, 24] {
                numOnes += (num >> (index - 1)) & 1
            }

            num <<= 1

            num |= (numOnes & 1)
        }

        let registerLine = textFieldRegister.stringValue
        if (!checkKey(key: registerLine)) {
            dialogAlert(message: "Invalid Register!")
            return
        }

        globalRegister = registerLine

        //let lenRegister = 24

        var register : Int32 = 0

        for index in registerLine.indices {
            register <<= 1
            register |= (registerLine[index] == "1") ? 1 : 0
        }

        var buff : UInt8 = 0
        for _ in 1...arrInputBytes.count {
            for _ in 1...8 {
                buff <<= 1
                buff |= ((register >> 23) & 1) == 1 ?  1 : 0
                takeNewBitRegister(&register)
                prbarCipher.increment(by: 1)
            }

            keyArr.append(buff)
            buff = 0
        }

        for index in arrInputBytes.indices {
            resArr.append(UInt8(arrInputBytes[index]) ^ keyArr[index])
        }

        prbarCipher.increment(by: 100)
        prbarAllProcess.increment(by: 33.33)

        inputByteFields(inputArr: keyArr, field: textFieldKey)
        inputByteFields(inputArr: resArr, field: textFieldOutputBytes)

        labelKeySize.stringValue = String(keyArr.count)
        labelOutputFileSize.stringValue = String(resArr.count)
        outputFileSize = String(resArr.count)
    }

    @IBAction func btnCheckAction(_ sender: NSButton) {
        func makeByte(byte : UInt8) -> String {
            var buffLine = ""
            var tmpByte : UInt8 = 128
            var counter = 0
            for _ in 1...8 {
                let char : Character = (byte & tmpByte == 0) ? "0" : "1"
                buffLine.append(char)

                tmpByte >>= 1

                counter += 1

                if counter == 4 {
                    buffLine.append(" ")
                }
            }
            return buffLine
        }

        let line = textFieldIndexCheckByte.stringValue
        if let index = Int(line) {
            labelCheckByte1.stringValue = makeByte(byte: arrInputBytes[index])
            labelCheckerByte2.stringValue = makeByte(byte: keyArr[index])
            labelCheckerByte3.stringValue = makeByte(byte: resArr[index])
        }
    }

    func makeByteString(byte : UInt8) -> String {
        var buffLine = ""
        var tmpByte : UInt8 = 128
        for _ in 1...8 {
            let char : Character = (byte & tmpByte == 0) ? "0" : "1"
            buffLine.append(char)
            tmpByte >>= 1
        }
        return buffLine
    }

    func inputByteFields(inputArr : [UInt8], field : NSTextField) {
        let firstBytesInputFile = 10
        let lastBytesInputFile = 10

        //for i in inputArr.indices {
        //field.stringValue.append("Firts \(firstBytesInputFile) bytes : ")
        for i in 0..<firstBytesInputFile {
            if inputArr.indices.contains(i) {
                var buffLine = makeByteString(byte: inputArr[i])
                buffLine.append(" ")

                field.stringValue.append(buffLine)
            }
        }
        field.stringValue.append("\n")
        //field.stringValue.append("\nLast \(lastBytesInputFile) bytes : ")

        for i in inputArr.count-lastBytesInputFile..<inputArr.count {
            if inputArr.indices.contains(i) {
                var buffLine = makeByteString(byte: inputArr[i])
                buffLine.append(" ")

                field.stringValue.append(buffLine)
            }
        }
    }

    func checkKey(key : String) -> Bool {
        if (key.count != 24) {
            return false
        }
        for char in key {
            if !["1", "0"].contains(char) {
                return false
            }
        }
        return true
    }

    func dialogAlert(message : String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = "Incorrect data"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destinationController as! InfoVewController

        destinationVC.nameFile = nameFile
        destinationVC.inputFileSize = outputFileSize
        destinationVC.outoutFileSize = outputFileSize
        destinationVC.register = globalRegister
    }

}
