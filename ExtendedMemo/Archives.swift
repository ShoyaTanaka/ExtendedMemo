//
//  Archives.swift
//  ExtendedMemo
//
//

import Foundation
import SwiftUI
import PencilKit
struct archives:View {
    @State var presentalert = false
    @Binding var currentList:[[String:String]]?
    @Binding var isShowingAlert:Bool
    @State var text: String = ""
    @State var alert:showalert?
    @State var rename:showrename
    init(){
        _isShowingAlert = Binding.constant(false)
        self._currentList = contentView.$pen.memos
        print(userDefaults.array(forKey: "Notes"))
        self.rename = showrename(list: self._currentList)
    }
    func update() {
        self.currentList = contentView.pen.memos
    }
    var body: some View {
        ZStack {
            rename
            alert
        VStack {
            Button(action: {() -> Void in

                DispatchQueue.main.async {
                    userDefaults.set({() -> [[String:String]] in
                                        var current = userDefaults.array(forKey: "Notes") as! [[String:String]]
                                        current.append(["\(arc4random())":"新規メモ"])
                        return current
                    }(), forKey: "Notes")
                }
                DispatchGroup().notify(queue: .main){
                do {
                    let currentmemo = userDefaults.array(forKey: "Notes") as! [[String:String]]
                    let newmemo = currentmemo.last!
                    let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("\(currentmemo[currentmemo.count - 1].first!.key)")
                    print(currentmemo[currentmemo.count - 1].keys)
                    print(1)
                    let newcanvas = PKDrawing()
                    let data = newcanvas.dataRepresentation()
                    try data.write(to:url)
//Fixed:リストに二つ表示されてしまう不具合(iPadOS 15.0にて確認)
//                    contentView.Pencil.penpro.memos?.append(newmemo)
                    self.currentList?.append(newmemo)
                    contentView.Pencil.PencilDelegate.url = url
                    contentView.Pencil.canvas.drawing = newcanvas
                    userDefaults.set("\(newmemo.first!.key)",forKey: "LastUUID")
                    userDefaults.set([UIScreen.main.bounds.width,UIScreen.main.bounds.height / 2],forKey:"\(newmemo.first!.key)")
                }
                catch {}
                }
            }, label: {Text("append")})
            List{
                ForEach(currentList!, id:\.self) { dic in
                HStack{
                Text(dic.first!.value as String)
                Spacer()
                }
                .contentShape(Rectangle())
/*                    contentView.Pencil.penpro.pointer = num
                    print(contentView.Pencil.pointer)
                    print(memos[contentView.Pencil.penpro.pointer].keys.first!)
                    contentView.Pencil.PencilDelegate.Note = true*/
            .onTapGesture {
                contentView.Pencil.penpro.uuid = "\(dic.first!.key)"
                userDefaults.set("\(dic.first!.key)",forKey: "LastUUID")
                print("UUID:\( contentView.Pencil.penpro.uuid)")
                contentView.Pencil.PencilDelegate.url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("\(dic.first!.key)")
                contentView.Pencil.PencilDelegate.Note = true
            }
            .contextMenu {
                    Button("写真として保存") {
                    isShowingAlert = true
                    let image = contentView.Pencil.canvas.drawing.image(from: CGRect(x: 0, y: 0, width: contentView.Pencil.canvas.contentSize.width, height: contentView.Pencil.canvas.contentSize.height), scale: 1.0)
                    let jpeg = image.jpegData(compressionQuality: 100)
                    DispatchQueue.main.async {
                        print(jpeg == nil)
                        if alert != nil {
                            alert!.vc!.present(alert!.vc!.alert, animated: true, completion: {})
                        }
                        else {
                            alert = showalert(show: Binding.constant(true),image: jpeg!)
                        }
                    }

                }

                Button("名前変更") {
                        rename.al.tar = dic.first!.key
                        rename.al.present(rename.al.alert, animated: true, completion: {})
                }
            }
                }
            .onDelete(perform: DeleteData)
            }
        }
        }

    }
    func DeleteData(num:IndexSet) {
        print(num.last!)
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(contentView.Pencil.penpro.memos![num.last!].first!.key)
        print("UUIDのキー:\(contentView.Pencil.penpro.memos![num.last!].first!.key)")
        do{
            try FileManager.default.removeItem(at: url)}
        catch{print("Error Files.")}
        currentList!.remove(atOffsets: num)
//known issue:削除を押した際のondeleteメソッドが正常に働かずファイルが削除されていない
//Fixed:正常に動作するように

//        contentView.pen.memos!.remove(atOffsets: num)
        if (contentView.pen.memos!.count == 0) {
            let random = arc4random()
            var newcanvas = PKDrawing()
            let data = newcanvas.dataRepresentation()
            contentView.Pencil.canvas.drawing = newcanvas
            userDefaults.set([[String(random):"新規メモ"]], forKey: "Notes")
            let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(String(random))
                try! data.write(to: url)
            contentView.pen.memos!.append([String(random):"新規メモ"])
            currentList! = [[String(random):"新規メモ"]]
            userDefaults.set(random,forKey: "LastUUID")
        }
        else if (num.last! + 1 > contentView.pen.memos!.count){
            contentView.Pencil.penpro.uuid = contentView.pen.memos![num.last! - 1].first!.key
            print("UUID:\(contentView.Pencil.penpro.memos![num.last! - 1].first!.key)")
            contentView.Pencil.PencilDelegate.Note = true
        }
        else {
            print("0番目です")
            contentView.Pencil.penpro.uuid = contentView.pen.memos![num.last!].first!.key
            print("UUID:\(contentView.Pencil.penpro.memos![num.last!].keys)")
            contentView.Pencil.PencilDelegate.Note = true
        }
        userDefaults.set(contentView.Pencil.penpro.uuid,forKey: "LastUUID")

        print("ここ")
        userDefaults.set(Penpro.memos, forKey: "Notes")
        print("*******:finish")
    }
}

