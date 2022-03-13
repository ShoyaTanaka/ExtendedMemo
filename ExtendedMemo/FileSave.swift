//
//  FileSave.swift
//  ExtendedMemo
//
//

import Foundation
import SwiftUI
struct showalert:UIViewControllerRepresentable {
    @Binding var isshow:Bool
    var vc:ViewController?
    init (show:Binding<Bool>,image:Data) {
        self._isshow = show
        vc = ViewController(show: $isshow,image:image)
    }
    func makeUIViewController(context: Context) -> ViewController {
        return vc!
    }

    class ViewController:UIViewController,UITextFieldDelegate {
        @Binding var isshow:Bool
        var currenttex = ""
        var image:Data
        init (show:Binding<Bool>,image:Data) {
            self._isshow = show
            self.image = image
            super.init(nibName: nil, bundle: nil)
        }
        required init?(coder: NSCoder) {
            fatalError("Error")
        }
        var alert = UIAlertController(title: "ファイル保存", message: "保存するファイル名を決めてください", preferredStyle: .alert)
        
        @objc func textDidChange(text :NSNotification){
            if (self.alert.textFields![0].text! == ""){
                alert.actions[1].isEnabled = false
            }
            else {
                print("treueeeee")
                alert.actions[1].isEnabled = true
            }
            self.currenttex = alert.textFields![0].text!
            print(self.alert.textFields![0].text!)
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            var flag = false
            let save = UIAlertAction(title: "保存", style: .default, handler: {_ in
                let doc = try! FileManager.default.contentsOfDirectory(at:FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],includingPropertiesForKeys: nil)
                let files = doc.map{$0.lastPathComponent}
                for x in files {
                    print(x)
                    if x == "\(self.currenttex).jpg"{
                        flag = true
                    }
                }
                if flag {
                    let cancel_2 = UIAlertAction(title: "キャンセル", style: .default, handler: {_ in
                        self.alert.textFields![0].text = ""
                    })
                    let override = UIAlertAction(title: "書き換え", style: .default, handler: {_ in
                        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(self.currenttex).jpg")
                        try! self.image.write(to: dir)
                        
                    })
                    self.alert = UIAlertController(title: "ファイル名エラー", message: "ファイル名 \(self.currenttex) は既に存在します。書き換えますか?", preferredStyle: .alert)
                    self.alert.addAction(cancel_2)
                    self.alert.addAction(override)
                    self.alert.preferredAction = override
                    self.present(self.alert, animated: true, completion: {})
                    return
                }
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(self.currenttex).jpg")
                try! self.image.write(to: dir)
                self.alert.textFields![0].text = ""
                
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: {_ in self.isshow = false
                self.alert.textFields![0].text = ""
            })
            if (isshow){
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            })
                alert.addAction(cancel)
          alert.addAction(save)
                alert.preferredAction = save
                alert.actions[1].isEnabled = false
            alert.textFields![0].delegate = self
            alert.textFields![0].addTarget(self, action: #selector(textDidChange(text:)), for: .editingChanged)
            DispatchQueue.main.async {
                self.present(self.alert, animated: true, completion: nil)
            }
            }
        }
    }

    func updateUIViewController(_ uiView: ViewController, context: Context) {
        //必要なので消すな
        if (isshow){}
        }
}


