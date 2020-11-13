//
//  NewsFeedCellController.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit

protocol NewsFeedCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
 }

final class NewsFeedCellController: NewsItemView {
    
    private let delegate: NewsFeedCellControllerDelegate
    private let cell: NewsFeedCell = NewsFeedCell.fromNib()
    private let onSelection: (() -> Void)
    
    init(delegate: NewsFeedCellControllerDelegate,
         onSelection: @escaping () -> Void) {
        self.delegate = delegate
        self.onSelection = onSelection
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func select() {
        onSelection()
    }
    
    func display(_ viewModel: NewsItemViewModel<UIImage>) {
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.snippet
        cell.dateLabel.text = viewModel.date
        cell.coverImageView.image = viewModel.image
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
