//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Ta Cheng on 2021/7/5.
//

import Foundation

public struct FeedItem:Equatable{
    let id:UUID
    let description:String?
    let location:String?
    let imageURL:URL
}
