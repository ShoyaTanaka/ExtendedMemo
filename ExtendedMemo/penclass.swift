//
//  penclass.swift
//  ExtendedMemo
//
//

import Foundation
import PencilKit
import SwiftUI
var Penpro = PencilProperty()
struct pencil:UIViewRepresentable {
    var pk:PKToolPicker
    var Scroll = UIScrollView()
    var canvas:PKCanvasView
    var random:UInt32?
    var selectNote:[String:String]?
    @ObservedObject var PencilDelegate:delegate
    @ObservedObject var penpro = Penpro
    init() {
        self.pk = PKToolPicker()
        self.canvas = PKCanvasView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2))
        self.canvas.isScrollEnabled = true

        if var archive:[[String:String]] = userDefaults.array(forKey: "Notes") as? [[String:String]]{
            print("こっちにきたぞ")
            print(archive)
            if (archive.count == 0) {
                let random = arc4random()
                archive.append(["\(random)":"新規メモ"])
                userDefaults.set(archive,forKey: "Notes")
                userDefaults.set("\(random)",forKey: "LastUUID")
                userDefaults.set([UIScreen.main.bounds.width,UIScreen.main.bounds.height / 2],forKey:"\(random)")
            }
            self.PencilDelegate = delegate()
            //userDefaultsに最後に選択したメモ番号があるかを確認(UUID)、なければ一番最後に作成されたメモデータを読みこむ。
            if let UUID = userDefaults.string(forKey: "LastUUID") {
                self.PencilDelegate.url = FileManager.default.urls(for: .libraryDirectory, in:.userDomainMask).first!.appendingPathComponent(UUID)
            }
            else {
                self.PencilDelegate.url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(archive.last!.first!.key)
            }
            //そのUUIDのuserDefaultsにCGFloatで補完された幅、長さのデータを読み出しNoteをtoggleすることでupdateUIViewを発動させる
            let size:[CGFloat] = userDefaults.object(forKey: "\(self.penpro.uuid)") as! [CGFloat]
            self.canvas.contentSize.width = size[0]
            self.canvas.contentSize.height = size[1]
            self.PencilDelegate.Note = true
            print(self.canvas.contentSize.height)
        }
        else {
            //userDefaultsにメモのデータリストがない場合の処理。
            print("保存されてないぞ")
            random = arc4random()
            var newcanvas = PKDrawing()
            let data = newcanvas.dataRepresentation()
            canvas.drawing = newcanvas
            userDefaults.set([[String(random!):"新規メモ"]], forKey: "Notes")
            self.PencilDelegate = delegate()
            let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(String(random!))
            self.PencilDelegate.url = url
            userDefaults.set([UIScreen.main.bounds.width,UIScreen.main.bounds.height / 2],forKey:"\(random!)")
            penpro.memos = [[String(random!):"新規メモ"]]
            do{
                try data.write(to: url)
            }
            catch {
            }
        }

        
    }
    class delegate:NSObject,PKCanvasViewDelegate,ObservableObject{
        @Published var Note = false
        var url:URL?
        var Notelist:[[String:String]]? = userDefaults.array(forKey: "Notes") as? [[String:String]]
        let directry = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        var height:CGFloat = 0
        var width:CGFloat = 0
        func canvasViewDrawingDidChange(_ canvasView:PKCanvasView){
            if height == 0 {
                height = canvasView.contentSize.height
            }
            if width == 0 {
                width = canvasView.contentSize.width
            }
           if ((canvasView.contentSize.height - (canvasView.contentOffset.y+UIScreen.main.bounds.height/2)) < 200){
            print("高さ増やした")
            canvasView.contentSize.height += 200
            height = canvasView.contentSize.height
            userDefaults.set([height,width],forKey:"\(contentView.Pencil.penpro.uuid)")
           }
           if (canvasView.contentSize.width - (canvasView.contentOffset.x+UIScreen.main.bounds.width) < 100) {
            canvasView.contentSize.width += 100
            print("幅増やした")
            width = canvasView.contentSize.width
            userDefaults.set([height,width],forKey:"\(contentView.Pencil.penpro.uuid)")
           }
            print(canvasView.drawing.bounds.height)
            if (Notelist == nil) {
                let random = contentView.Pencil.random
                userDefaults.set([random:"新規メモ"],forKey: "Notes")
                Notelist = userDefaults.array(forKey: "Notes") as? [[String:String]]
                url = directry.appendingPathComponent("\(Notelist![0].first!.key)")
            }
            do{
                let data = canvasView.drawing.dataRepresentation()
                try data.write(to: url!)
            }
            catch {}
        }

        
    }
    func makeUIView(context: Context) -> PKCanvasView{
        print(UIScreen.main.bounds.height)
        canvas.contentOffset = CGPoint.zero
        canvas.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 1.0)
        canvas.drawingGestureRecognizer.isEnabled = true
        canvas.delegate = PencilDelegate
        pk.addObserver(canvas)
        pk.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {/*
        uiView.delegate = PencilDelegate
        pk.addObserver(canvas)
        pk.setVisible(true, forFirstResponder: uiView)
        
        uiView.becomeFirstResponder()*/
            print("Detect")
        if (PencilDelegate.Note) {
            do {
                let draw =  try PKDrawing(data: try Data(contentsOf: FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self.penpro.uuid)")))
                let sized = userDefaults.object(forKey: "\(self.penpro.uuid)")
                //sizeオブジェクトにてnil参照が発生しているので修正するように(2021/11/15)
                let size:[CGFloat] = userDefaults.object(forKey: "\(self.penpro.uuid)") as! [CGFloat]
                contentView.Pencil.canvas.contentSize.width = size[1]
                contentView.Pencil.canvas.contentSize.height = size[0]
                contentView.Pencil.canvas.drawing = draw
            }
            catch {
                print("Error")
            }
            print("OKOK")
            PencilDelegate.Note = false
        }
        if (penpro.Onlypencil){
            uiView.drawingPolicy = .pencilOnly
            userDefaults.set(true,forKey: "allowFin")
        }
        else{
            uiView.drawingPolicy = .anyInput
            userDefaults.set(false,forKey: "allowFin")
        }
        
    }
}
class PencilProperty:ObservableObject {
    @Published var memos:[[String:String]]? = userDefaults.array(forKey: "Notes") as? [[String:String]]
    @Published var uuid = "0"
    @Published var Onlypencil:Bool = userDefaults.bool(forKey: "allowFin")
    init() {
        if (memos == nil) {
        memos = []
        }
        print("memos:\(memos!)")
    }
}
