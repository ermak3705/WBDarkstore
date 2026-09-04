//
//  CachedAsyncImage.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.08.2026.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }

    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        if let cached = await ImageCache.shared.image(for: url) {
            phase = .success(Image(uiImage: cached))
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(URLError(.cannotDecodeContentData))
                return
            }
            await ImageCache.shared.store(data: data, image: uiImage, for: url)
            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }

    var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }
}
