//
//  ImageCache.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.08.2026.
//

import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private let fileManager = FileManager.default

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    func image(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        let fileURL = diskCacheURL.appendingPathComponent(fileName(for: url))
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key)
            return image
        }

        return nil
    }

    func store(data: Data, image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        memoryCache.setObject(image, forKey: key)

        let fileURL = diskCacheURL.appendingPathComponent(fileName(for: url))
        try? data.write(to: fileURL)
    }

    private func fileName(for url: URL) -> String {
        String(url.absoluteString.hashValue)
    }
}
