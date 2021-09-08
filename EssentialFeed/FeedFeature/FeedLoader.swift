//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ta Cheng on 2021/7/5.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}


protocol FeedLoader {
    func load(completion:@escaping(LoadFeedResult)->Void)
}
