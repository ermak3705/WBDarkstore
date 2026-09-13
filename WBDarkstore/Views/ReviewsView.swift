//
//  ReviewsView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 12.08.2026.
//

import SwiftUI
import WBDesignSystemKit
enum ReviewSortOption: String, CaseIterable, Identifiable {
    case dateDescending = "Сначала новые"
    case dateAscending = "Сначала старые"
    case ratingDescending = "Сначала лучшие"
    case ratingAscending = "Сначала худшие"
    
    var id: String { rawValue }
}

struct ReviewsView: View {
    private let productId: String
    private let initialDetail: ProductDetail
    
    @Environment(ServiceLocator.self ) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var showWriteReview = false
    @State private var sortOption: ReviewSortOption = .dateDescending

    init(detail: ProductDetail) {
        self.productId = detail.id
        self.initialDetail = detail
    }
    
    private var detail: ProductDetail {
        services.productService.productDetail ?? initialDetail
    }
    
    private var summary: ReviewsSummary {
        ReviewsSummary(reviews: detail.reviews)
    }

    private var sortedReviews: [Review] {
        switch sortOption {
        case .dateDescending:
            return detail.reviews.sorted {$0.createdAt > $1.createdAt}
        case .dateAscending:
            return detail.reviews.sorted {$0.createdAt < $1.createdAt}
        case .ratingDescending:
            return detail.reviews.sorted {$0.rating > $1.rating}
        case .ratingAscending:
            return detail.reviews.sorted {$0.rating < $1.rating}
        }
    }
    
    private var header: some View {
        HStack {
            Text("Отзывы")
                .font(DSTypography.title)
                .foregroundColor(.black)
            Text("\(summary.totalCount)")
                .font(DSTypography.title)
                .foregroundColor(.gray)
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
            }
        }
    }

    private var ratingSummary: some View {
        HStack(alignment: .center, spacing: 20) {
            Text(String(format: "%.1f", summary.averageRating))
                .font(.system(size: 94, weight: .light))

            VStack(alignment: .leading, spacing: 4) {
                ForEach((1...5).reversed(), id: \.self) { stars in
                    ratingBar(stars: stars)
                }
            }
        }
    }

    private func ratingBar(stars: Int) -> some View {
        let hasReviews = summary.count(for: stars) > 0

        return HStack(spacing: 16) {
            HStack(spacing: 2) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(hasReviews ? .black : Color(uiColor: .systemGray4))
                }
            }
            .frame(width: 72, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .systemGray5))
                    Capsule()
                        .fill(Color.black)
                        .frame(width: geometry.size.width * summary.percentage(for: stars))
                }
            }
            .frame(height: 4)

            Text("\(summary.count(for: stars))")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 24, alignment: .trailing)
        }
    }

    private var writeReviewButton: some View {
        Button {
            showWriteReview = true
        } label: {
            Text("Написать отзыв")
                .font(DSTypography.privestiSudaButton)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DSGradients.smoky)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var sortMenu: some View {
        HStack {
            Spacer()
            Menu {
                ForEach(ReviewSortOption.allCases) { option in
                    Button {
                        sortOption = option
                    } label: {
                        if option == sortOption {
                            Label(option.rawValue, systemImage: "checkmark")
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(sortOption.rawValue)
                        .font(DSTypography.headline)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(DSTypography.headline)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(uiColor: .systemGray6))
                .clipShape(Capsule())
            }
        }
    }

    private var reviewsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sortedReviews) { review in
                reviewCard(review)
            }
        }
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(index < review.rating ? .black : Color(uiColor: .systemGray4))
                    }
                }
                Text(review.author)
                    .font(.system(size: 14, weight: .medium))
                Text(review.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Text(review.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
        }
        .padding(12)
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    ratingSummary
                    writeReviewButton
                    sortMenu
                    reviewsList
                }
                .padding(16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showWriteReview, onDismiss: {
                Task {
                    await services.productService.loadProductDetail(id: productId)
                }
            }) {
                WriteReviewView(detail: detail)
            }
        }
    }
}
