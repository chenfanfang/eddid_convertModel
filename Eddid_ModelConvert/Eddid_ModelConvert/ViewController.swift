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
        //       format的处理
        //=======================
        var formatString = self.formatTextView.string
        formatString = formatString.replacingOccurrences(of: " ", with: "")
        let formatArray = formatString.components(separatedBy: "\n")
        var formatDict: [String: String] = [:]
        for subStr in formatArray where subStr.isEmpty == false {
            let keyValueArray = subStr.components(separatedBy: ":")
            if keyValueArray.count != 2 {
                showErrorMessage("format出错, 出错位置为: \(subStr)")
                return
            }
            formatDict[keyValueArray.first!] = keyValueArray.last!
        }
        //=======================
        //       读取输入框
        //=======================
        var inputString = self.inputTextView.string
        inputString = inputString.replacingOccurrences(of: "       ", with: "")
        var inputArray: [String] = inputString.components(separatedBy: "\n")
        inputArray = inputArray.filter { (string) -> Bool in
            return string.isEmpty == false
        }
        if inputArray.count % 3 != 0 {
            self.showErrorMessage("输入框内容有误，每个属性必须有且只有三行数据,\n\n第一行为: 属性名称\n第二行为: 属性注释\n第三行为: 属性类型")
            return
        }
        //=======================
        //       拼接数据
        //=======================
        var outPutString: String = ""
        for index in stride(from: 0, to: inputArray.count - 1, by: 3) {
            /// 属性
            let property = inputArray[index]
            /// 注释
            let annotation = inputArray[index + 1]
            /// 类型匹配的key
            let formatKey: String = inputArray[index + 2]
            /// 类型
            var type: String
            if let mapType = formatDict[formatKey], mapType.isEmpty == false {
                type = mapType
            } else {
                type = formatKey + " // 类型匹配失败，请自行进行修改"
            }
            /// 祖师
            outPutString.append("/// \(annotation)\n")
            
            outPutString.append("var \(property): \(type)\n")
            if self.lineFeedSwitch.state == .on {
                outPutString.append("\n")
            }
        }
        self.outPutTextView.string = outPutString
        //print(inputArray)
    }
    @IBAction func copyBtnClick(_ sender: Any) {
        let pboard = NSPasteboard.general           // 1
        pboard.clearContents()
        pboard.setString(self.outPutTextView.string, forType: .string)  // 3
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
