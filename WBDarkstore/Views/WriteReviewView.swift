//
//  WriteReviewView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 12.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct WriteReviewView: View {
    let detail: ProductDetail
    @Environment(\.dismiss) private var dismiss
    @Environment(ServiceLocator.self) private var services
    
    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didSubmitSuccessfully = false
    
    private var productPreview: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 60, height: 60)
                .overlay {
                    AsyncImage(url: detail.imageURL) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(detail.title)
                    .font(.system(size: 14, weight: .semibold))
                Text(detail.description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
    }
    
    private var ratingPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Оценка")
                .font(.system(size: 16, weight: .semibold))
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        rating = star
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
    
    private var commentField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Комментарий")
                .font(.system(size: 16, weight: .semibold))
            
            TextEditor(text: $comment)
                .frame(height: 120)
                .padding(8)
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var submitButton: some View {
        VStack(spacing: 8) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
            
            DSButton(title: isSubmitting ? "Отправка..." : "Оставить отзыв", isLoading: isSubmitting) {
                Task {
                    await submitReview()
                }
            }
            .disabled(rating == 0 || comment.isEmpty || isSubmitting)
        }
    }
    
    private func submitReview() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        
        do {
            try await services.productService.submitReview(
                productId: detail.id,
                rating: rating,
                content: comment
            )
            didSubmitSuccessfully = true 
        } catch {
            errorMessage = "Не удалось отправить отзыв. Попробуйте ещё раз."
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    productPreview
                    ratingPicker
                    commentField
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom) {
                submitButton
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
            }
            .navigationTitle("Отзыв о товаре")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .fullScreenCover(isPresented: $didSubmitSuccessfully) {
                ReviewSubmittedView{
                    dismiss()
                }
            }
        }
    }
}
