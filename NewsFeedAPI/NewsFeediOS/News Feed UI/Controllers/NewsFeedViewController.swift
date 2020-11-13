//
//  NewsFeedViewController.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit

public class NewsFeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshViewController?
    private var pagingController: PagingController?
    private var tableModel = [NewsFeedCellController]()
    
    func appened(_ newItems: [NewsFeedCellController]) {
        let startIndex = tableModel.count
        let endIndex = startIndex + newItems.count
        tableModel += newItems
        
        tableView.insertRows(at: (startIndex ..< endIndex).map { index in
            IndexPath(item: index, section: 0)
        }, with: .fade)
    }
    
    convenience init(refreshController: FeedRefreshViewController, pagingController: PagingController) {
        self.init()
        self.refreshController = refreshController
        self.pagingController = pagingController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
    
    func setupView() {
        refreshControl = refreshController?.view
        tableView.separatorStyle = .none
        tableView.register(NewsFeedCell.nib(), forCellReuseIdentifier: String(describing: NewsFeedCell.self))
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).select()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> NewsFeedCellController {
        return tableModel[indexPath.row]
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard scrollView.isDragging else { return }
      
      let offsetY = scrollView.contentOffset.y
      let contentHeight = scrollView.contentSize.height
        let leadingBufferScreenfuls = 1.5 * scrollView.frame.height
        if (offsetY > contentHeight - leadingBufferScreenfuls) {
        pagingController?.loadNextPage()
      }
    }
}
