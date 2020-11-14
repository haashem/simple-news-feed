//
//  SceneDelegate.swift
//  NYTimesNow
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit
import NewsFeediOS
import NewsFeedAPI
import NewsFeedFeature
import Networking

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)

        navigationController = UINavigationController(rootViewController: createNewsFeedScene())
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()
    }

}

private extension SceneDelegate {
    func createNewsFeedScene() -> NewsFeedViewController {
        let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        let feedLoader = NYTimesFeedLoader(url:URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=election&api-key=yutoXQcmaMIdjY3JDr1QA9BqHAD3m59x")!, client: client)
        let imageLoader = RemoteImageDataLoader(client: client)
        return FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader, selection: { [unowned self] newsItem in
            
            self.navigationController?.pushViewController(FeedUIComposer.feedDetailsWith(url: newsItem.articleUrl), animated: true)
        })
    }
}

