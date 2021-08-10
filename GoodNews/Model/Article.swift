//
//  Article.swift
//  GoodNews
//
//  Created by 大江祥太郎 on 2021/08/08.
//

import Foundation

struct ArticleList: Codable {
    let articles: [Article]
    let status:String
    let totalResults:Int
  
}

struct Article: Codable{
    let title:String
    let description:String
    
    
}
