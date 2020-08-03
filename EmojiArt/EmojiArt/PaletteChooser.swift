//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Thomas, Samuel B. (Student) on 7/8/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    @State private var showPaletteEditor = false
    //almost always private
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
            }
            .popover(isPresented: $showPaletteEditor){
                PaletteEditor(chosenPalette: self.$chosenPalette, isShowing: self.$showPaletteEditor)
                    .environmentObject(self.document)
                .frame(minWidth: 300, minHeight: 500)
            }
        }
    .fixedSize(horizontal: true, vertical: false)
       // .onAppear { self.chosenPalette = self.document.defaultPalette}
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                Text("PaletteEditor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: { Text("Done") } ).padding()
                }
            }
            Divider()
            Form {
                Section {
//                    header: Text("Palette Name")
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                //.padding()
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                    if !began {
                        self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                        self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                                .onTapGesture {
                                    self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                            }
                        }
                    .frame(height: self.height)
                    }
                }
            //Text(self.document.paletteNames[self.chosenPalette] ?? "").padding()
            //Spacer()
        }
        .onAppear{ self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1)/6) * 70 + 70
    }
    let fontSize: CGFloat = 40
}

//struct PaletteChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
//    }
//}

