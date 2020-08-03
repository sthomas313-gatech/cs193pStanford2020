//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Thomas, Samuel B. (Student) on 7/2/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                HStack {
                    ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag {
                                    NSItemProvider(object: emoji as NSString) }
                            }
                        }
                    }
                    //.layoutPriority(1)
                    //.onAppear { self.chosenPalette = self.document.defaultPalette }
                }
            //.padding(.horizontal)
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: self.document.backgroundImage)
                        .scaleEffect(self.zoomScale)
                        .offset(self.panOffset)
                )
                    .gesture(self.doubleTapToZoom(in: geometry.size))
                if self.isLoading {
                    Image(systemName: "hourglass").imageScale(.large).spinning()
                } else {
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            //.font(self.font(for: emoji))
                            .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.zoomGesture())
                .gesture(self.panGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image","public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                  
                }
        .navigationBarItems(trailing: Button(action: {
            if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                self.confirmBackgroundPaste = true
            } else {
                self.explainBackgroundPaste = true
            }
        }, label: {
            Image(systemName: "doc.on.clipboard").imageScale(.large)
                .alert(isPresented: self.$explainBackgroundPaste) {
                    return Alert(
                        title: Text("Paste background"),
                        message: Text("Copy the URL of an Image and touch this button to make it the background of your document."),
                        dismissButton: .default(Text("Ok")))
            }
        }))
            }
        .zIndex(-1)
        }
            .alert(isPresented: self.$confirmBackgroundPaste) {
            return Alert(
                title: Text("Paste background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("Ok")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
     var isLoading: Bool {
          document.backgroundURL != nil && document.backgroundImage == nil
      }
   
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom,vZoom)
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale //*ourGestureStateInOut*//
                , transaction in
               gestureZoomScale = latestGestureScale
                
        }
            .onEnded { finalGestureScale in
                self.document.steadyStateZoomScale += finalGestureScale
        }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                self.zoomToFit(self.document.backgroundImage, in: size)
            }
        }
    }
    
//    private func font(for emoji: EmojiArt.Emoji) -> Font {
//        Font.system(size: emoji.fontSize * zoomScale)
//
//    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            //print("dropped \(url)")
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}

// wouldnt want to do this
//extension String: Identifiable {
//    public var id: String { return self }
//}
