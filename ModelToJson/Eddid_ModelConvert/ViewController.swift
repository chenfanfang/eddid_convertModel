//
//  ViewController.swift
//  Eddid_ModelConvert
//
//  Created by IMac  on 2021/4/19.
//

import Cocoa

private let FormatKey = "FormatKey"

private let defaultFormat = "" +
"string: String?\n" +
"number: Double?\n" +
"array: [<#存储类型#>]?\n" +
"string(date-time): String?\n" +
"boolean: Bool?\n" +
"integer(int64): Int64?\n" +
"integer(int32): Int32?\n" +
"integer(int16): Int16?\n"

class ViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet weak var formatTextView: NSTextView!
    
    @IBOutlet var inputTextView: NSTextView!
    
    @IBOutlet var outPutTextView: NSTextView!
    
    @IBOutlet var rightOutPutTextView: NSTextView!
    
    @IBOutlet weak var lineFeedSwitch: NSSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatString: String = UserDefaults.standard.string(forKey: FormatKey) ?? defaultFormat
        self.formatTextView.string = formatString
        self.formatTextView.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    @IBAction func saveFormatBtnClick(_ sender: Any) {
        UserDefaults.standard.setValue(self.formatTextView.string, forKey: FormatKey)
        UserDefaults.standard.synchronize()
    }
    @IBAction func resetFormat(_ sender: Any) {
        UserDefaults.standard.setValue(defaultFormat, forKey: FormatKey)
        self.formatTextView.string = defaultFormat
    }
    
    @IBAction func convertBtnClick(_ sender: Any) {
        //=======================
        //      左边
        //=======================
        let flag: String = "flag____"
        let trailFlag: String = "____flag"
        let neddAddPrefix: String = "cmf_rsp_"
        let needAddSuffix: String = "__property"
        //=======================
        //       读取输入框
        //=======================
        var inputString = self.inputTextView.string
        inputString = inputString.replacingOccurrences(of: "var", with: flag)
        inputString = inputString.replacingOccurrences(of: ":", with: trailFlag)
        inputString = inputString.replacingOccurrences(of: " ", with: "")
        var inputArray: [String] = inputString.components(separatedBy: "\n")
        inputArray = inputArray.filter { (string) -> Bool in
            if string.contains(flag) {
                return true
            }
            return false
        }
        //=======================
        //       拼接数据
        //=======================
        var outPutString: String = ""
        for str in inputArray {
            let element = str.components(separatedBy: flag).last!.components(separatedBy: trailFlag).first!
            let newLineString: String = "\"\(neddAddPrefix)\(element)\(needAddSuffix)\": \"\(element)\",\n"
            outPutString.append(contentsOf: newLineString)
        }

        self.outPutTextView.string = outPutString
        //print(inputArray)
        //=======================
        //        右边
        //=======================
        var rightInputString = self.inputTextView.string
        rightInputString = rightInputString.replacingOccurrences(of: "var   ", with: "var ")
        rightInputString = rightInputString.replacingOccurrences(of: "var  ", with: "var ")
        rightInputString = rightInputString.replacingOccurrences(of: "  :", with: ":")
        rightInputString = rightInputString.replacingOccurrences(of: " :", with: ":")
        rightInputString = rightInputString.replacingOccurrences(of: "var ", with: "var \(neddAddPrefix)")
        rightInputString = rightInputString.replacingOccurrences(of: ":", with: "\(needAddSuffix):")
        self.rightOutPutTextView.string = rightInputString
        
    }
    @IBAction func copyBtnClick(_ sender: Any) {
        let pboard = NSPasteboard.general           // 1
        pboard.clearContents()
        pboard.setString(self.outPutTextView.string, forType: .string)  // 3
    }
    
    @IBAction func rightcopyBtnClick(_ sender: Any) {
        let pboard = NSPasteboard.general           // 1
        pboard.clearContents()
        pboard.setString(self.rightOutPutTextView.string, forType: .string)  // 3
    }
    
}

//=================================================================
//                    NSTextViewDelegate
//=================================================================
// MARK: - NSTextViewDelegate

extension ViewController {
    
}

//=================================================================
//                           显示错误信息
//=================================================================
// MARK: - 显示错误信息
extension ViewController {
    
    func showErrorMessage(_ errorMessage: String) {
        let alert = NSAlert()
        alert.messageText = errorMessage
        alert.addButton(withTitle: "知道了")
        alert.alertStyle = .critical
        alert.runModal()
    }
}
