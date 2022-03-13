//
//  ContentView.swift
//  ExtendedMemo
//
//

import SwiftUI
import PencilKit
import Foundation
var Tex = "https://www.google.co.jp"
struct ContentView: View {
    @State var Pencil = pencil()
    @ObservedObject var pen = Penpro
    @State var ViewSettings = false
    @State var Menu = true
    @State var savealert = false
    @State var loadalert = false
    @State var hidden = false
    @State var WebView = instances[lastnum]//instancesにWeb()を格納する
    @State var progress = Progress()
    @State var menuisshowed = false
    
    @StateObject var sing = instances[lastnum]!.singlec
    var Search = TexField()
    @State var show = true
    
   
    var body: some View {
        ZStack(alignment:.topLeading){
        VStack{
            HStack {
                Button(action: {() -> Void in
                    menuisshowed = true
                    hidden.toggle()
                }, label: {Image(systemName: "list.bullet")})
                Spacer()
                Button(action: {() -> Void in
                    Pencil.pk.addObserver(Pencil.canvas)
                    Pencil.pk.setVisible(true, forFirstResponder: Pencil.canvas)
                    Pencil.canvas.becomeFirstResponder()
                }, label: {
                    Image(systemName: "pencil.circle")
                })
            }
            HStack {
            Pencil.alert(isPresented: instances[lastnum]!.$singlec.load, content: {() -> Alert in Alert(title:Text("Test"))})
            }
            ZStack(alignment: .bottom){
            WebView.gesture(DragGesture()
                                .onChanged({value in
            if (value.translation.height < 0){
                    Menu = false
                            }
                    else if (value.translation.height > 0){
                        Menu = true
                    }
                                }))
                VStack{
                    progress
            if (Menu){
                
            HStack{

                Button(action: {instances[lastnum]!.controller!.webview.goBack()}){Image(systemName: "arrow.left")}.disabled(sing.cangoback)
                Button(action: {instances[lastnum]!.controller!.webview.goForward()}){Image(systemName: "arrow.right")}.disabled(sing.cangoforward)
                Button("Home"){
                    instances[lastnum]!.controller!.webview.load(URLRequest(url:URL(string: "https://www.google.co.jp")!))
                        }
                Search.frame(width: 2*UIScreen.main.bounds.width/3, height: 20.0)

            Button("Settings"){
                    ViewSettings = true
                }.sheet(isPresented: $ViewSettings, content: {
                    Settings()
                })
            }
            }
                }.background(Color.white)
            }
  
    }
        .sheet(isPresented: self.$menuisshowed, content: {
            archives()
        })
                               
            
    }
    }
}
struct memomenu:View {
    var arc = archives()
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color.black.opacity(0.3).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2, alignment: .topTrailing).onTapGesture {
                
            }
            arc.transition(.slide).frame(width:200 , height: UIScreen.main.bounds.height/2, alignment:.topLeading).background(Color(red: 0.2, green: 0.2, blue: 0.2))
        }
    }
}
struct Settings:View {
    @State var doc = try! FileManager.default.contentsOfDirectory(at:FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0],includingPropertiesForKeys: nil)
    
    var body:some View {
        Toggle(isOn: contentView.$pen.Onlypencil, label: {Text("Apple Pencilのみで描画")})
        /*ForEach (0 ..< doc.map{$0.lastPathComponent}.count) {num in
            Text("\(doc.map{$0.lastPathComponent}[num])")
        }
                .navigationBarTitle("Settings")
                .toolbar {
                }*/
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Progress:UIViewRepresentable {
    var Progress = UIProgressView()
    func makeUIView(context: Context) -> UIProgressView {
        return Progress
    }
    func updateUIView(_ uiView: UIProgressView, context: Context) {
            
    }
}
