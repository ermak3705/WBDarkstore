//
//  CatalogView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//
import Foundation
import SwiftUI

struct CatalogView: View {
    @State private var service: CategoriesService
    
    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]
    
    init(service: CategoriesService) {
        _service = State(initialValue: service)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if service.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(service.categories) { category in
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
                                            .white.opacity(0.8),
                                            .white.opacity(0.9),
                                            .white.opacity(0.95),
                                            .white
                                        ],
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .frame(height: geometry.size.height * 0.5)
                                        .position(x: geometry.size.width / 2,
                                                  y: geometry.size.height * (3/4) )
                                        
                                    }
                                }
                                .overlay(alignment: .bottomLeading) {
                                    Text(category.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                        .lineLimit(2)
                                        .padding(.bottom, 8)
                                        .padding(.leading, 8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                        }
                    }
                    .padding(16)
                }
            }
            .task {
                await service.loadCategories()
            }
            .navigationTitle("Каталог")
        }
    }
}

#Preview {
    CatalogView(service: CategoriesService(client: try! APIClientFactory.makeClient(token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJta29uZGFrb3ZhIiwiaWF0IjoxNzgyOTIyMDMzLCJqdGkiOiIwMmRhNTBhZS02YzQ2LTQ4MTItYjRhNi0xOTMzYmRkMGU5YzMiLCJuaWNrbmFtZSI6ImVybWFrb3YuaWx5YSIsImlzVGVhY2hlciI6dHJ1ZX0.a7pfvXyTVtnH7zoeP5vLoJEyM7-0DMYDwAD7yTIS8LaK34x4i7bq5dzJSBTzv4FQ-r0OfnLbMrpsUPMWGzYXnHo5QM2RElC4tSiPN9VRacXyosz7Hx8B6uAPPud25uajy3WJFsJsM12_KNMDX3Xcfew2oMdXaEQiOPbrO423AJwEZJ1QqadHvn4wM1f4OLzhakH3GYDh45OTxcI78vN2A3wWfdQmpp73GTje5xHn9D31Hq-p9zWt3HSb8JDGX-yeqXbdZKpFuTX7Ho3q5-mzQAimQmnEMI1viDXUJ2D0MYiNosV6oyk7VlNVq73kYNciG_wn4_UHM09LSwSUtYD0_w")))
}
