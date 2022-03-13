//
//  memoRename.swift
//  ExtendedMemo
//
//

import Foundation
import SwiftUI
struct showrename:UIViewControllerRepresentable {
    var tarstr:String = ""
    @Binding var lis:[[String:String]]?
    var al:renamealert
    init (list:Binding<[[String:String]]?>) {
        self._lis = list
        self.al = renamealert(lis: self._lis)
    }
    func makeUIViewController(context: Context) -> renamealert {
        return al
    }
    func updateUIViewController(_ uiViewController: renamealert, context: Context) {
    }
}
class renamealert:UIViewController,UITextFieldDelegate {
    var tar:String = ""
    var currenttex = ""
    @Binding var list:[[String:String]]?
    init (lis:Binding<[[String:String]]?>) {
    self._list = lis
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    let alert = UIAlertController(title: "名称変更", message: "変更する名前を決めてください", preferredStyle: .alert)
    override func viewDidLoad() {
        let change = UIAlertAction(title: "変更", style: .default, handler: {_ in
            for x in 0..<contentView.pen.memos!.count {
                if contentView.pen.memos![x].first!.key == self.tar {
                    print(contentView.pen.memos![x])
                    let uu = contentView.pen.memos![x].first!.key
                    self.list![x] = [uu:self.currenttex]
                    userDefaults.set(self.list!,forKey: "Notes")
                    self.alert.textFields![0].text = ""
                }
            }
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        alert.addTextField(configurationHandler: {(text:UITextField) -> Void in })
        alert.textFields![0].addTarget(self, action: #selector(textChange(tex:)), for: .editingChanged)
        alert.addAction(cancel)
        alert.addAction(change)
        alert.preferredAction = change
        present(self.alert, animated: true, completion: {})
        return
    }
    @objc func textChange(tex:NSNotification) {
        currenttex = alert.textFields![0].text!
        print(currenttex)
    }
}
