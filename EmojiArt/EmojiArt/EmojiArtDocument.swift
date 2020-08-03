//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Thomas, Samuel B. (Student) on 7/2/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable
{
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    @Published //work around for property observer with property wrappers
    private var emojiArt: EmojiArt //= EmojiArt()
//    {
//        willSet {
//            objectWillChange.send()
//        }
//        didSet {
//            //print("json = \(emojiArt.json?.utf8 ?? "nill")")
//            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
//        }
//    }
    //private static let untitled = "EmojiArtDocument.Untitled"
    
    private var autosaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            //print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat ) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
            }
        }
    var backgroundURL: URL? {
    get {
        emojiArt.backgroundURL
    }
    set {
        emojiArt.backgroundURL = newValue?.imageURL
        fetchBackgroundImageData()
        }
    }
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
//            let session = URLSession.shared
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map{ data, URLResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .assign(to: \EmojiArtDocument.backgroundImage, on: self)
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async {
//                        if url == self.emojiArt.backgroundURL {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
