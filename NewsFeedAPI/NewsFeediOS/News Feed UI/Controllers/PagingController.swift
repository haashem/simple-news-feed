//
//  NewsFeedPagingController.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation

protocol PagingControllerDelegate {
  func didRequestPage(page: Int)
}

final class PagingController {

  private let delegate: PagingControllerDelegate
  private var viewModel: PagingViewModel?
  
  init(delegate: PagingControllerDelegate) {
    self.delegate = delegate
  }

  func loadNextPage() {
    
    guard let viewModel = viewModel, !viewModel.isLoading else {
        return
    }

    delegate.didRequestPage(page: viewModel.nextPage)
  }

}

extension PagingController: PagingView {
  func display(_ viewModel: PagingViewModel) {
    self.viewModel = viewModel
  }
}
