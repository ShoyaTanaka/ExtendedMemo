//
//  URLText.swift
//  ExtendedMemo
//
//

import Foundation
import SwiftUI
class text:UIViewController,UITextFieldDelegate {
    var Width:CGFloat = 20
    var Text:UITextField
    init() {
        Text = UITextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("text init error.")
    }
    override func loadView() {
        Text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        Text.backgroundColor = UIColor.lightGray
        Text.text = Tex
        view = Text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Text.delegate = self
        Text.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.frame = CGRect(x:0,y:0,width:UIScreen.main.bounds.width - 40,height: 20)
        return true
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        let urldetect = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let res = urldetect?.matches(in: textField.text!, options: .reportCompletion, range: NSMakeRange(0, textField.text!.count))
        print("res:\(res!)")
        if res! != [] {
            if verifyurl(url: textField.text!) {
                instances[lastnum]!.controller!.webview.load(URLRequest(url: URL(string:"http://"+textField.text!)!))
            }
            instances[lastnum]!.controller!.webview.load(URLRequest(url: URL(string:textField.text!)!))
        }
        else {
            instances[lastnum]!.controller!.webview.load(URLRequest(url:URL(string:"https://www.google.com/search?q=\(textField.text!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)")!))
        }
        return true
    }
}
struct TexField:UIViewControllerRepresentable {
    var TextField = text()
    func makeUIViewController(context: Context) -> text {
        return TextField
    }
    func updateUIViewController(_ uiViewController: text, context: Context) {
        
    }
}
func verifyurl(url:String) -> Bool {
    URLSession.shared.dataTask(with:URLRequest(url: URL(string: "https://\(url)")!,cachePolicy: .reloadIgnoringCacheData,timeoutInterval: 0.5)) { data, response, error in
        if let err = error as NSError? {
            if err.domain == NSURLErrorDomain,
                err.code == NSURLErrorTimedOut {
                print("timeout")
                return
            }
            
        }
        guard let d = data, let s = String(data: d, encoding: .utf8) else { return }
        print(s)
    }.resume()
    return true
}
