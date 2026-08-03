//
//  CatalogView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//
import Foundation
import SwiftUI

struct CatalogView: View {
    @Environment(ServiceLocator.self) private var services

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            if services.categoryService.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(services.categoryService.categories) { category in
                        NavigationLink(value: category) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .aspectRatio(115/132, contentMode: .fit)
                                .overlay {
                                    AsyncImage(url: category.imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        case .empty:
                                            ProgressView()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                .overlay {
                                    GeometryReader { geometry in
                                        LinearGradient(colors: [
                                            .clear,
                                            .white.opacity(0.4),
                                            .white.opacity(0.5),
                                            .white.opacity(0.6),
                                            .white.opacity(0.8),
                                            .white.opacity(0.9),
                                            .white.opacity(0.95),
                                            .white
                                        ],
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .frame(height: geometry.size.height * (1/3))
                                        .position(x: geometry.size.width / 2,
                                                  y: geometry.size.height * (5/6))
                                    }
                                }
                                .overlay(alignment: .bottomLeading) {
                                    Text(category.name)
                                        .font(.system(size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                        .padding(.bottom, 6)
                                        .padding(.leading, 8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .task {
            await services.categoryService.loadCategories()
        }
        .navigationTitle("Категории")
    }
}

#Preview {
    NavigationStack {
        CatalogView()
            .environment(ServiceLocator())
    }
}
