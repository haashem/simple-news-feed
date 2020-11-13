//
//  NewsItemPresenter.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import NewsFeedFeature

protocol NewsItemView {
    associatedtype Image
    
    func display(_ model: NewsItemViewModel<Image>)
}

final class NewsItemPresenter<View: NewsItemView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: NewsItem) {
        view.display(NewsItemViewModel(title: model.title, snippet: model.snippet, image: nil, date: model.date.toString(), isLoading: model.imageUrl != nil, shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(NewsItemViewModel(title: model.title, snippet: model.snippet, image: image, date: model.date.toString(), isLoading: false, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: NewsItem) {
        view.display(NewsItemViewModel(title: model.title, snippet: model.snippet, image: nil, date: model.date.toString(), isLoading: false, shouldRetry: true))
    }
}

private extension Date {
    
    func toString(format: String = "MMM dd, yyyy") -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.dateFormat = format
            return formatter.string(from: self)
    }
}
