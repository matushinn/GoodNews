//
//  NewsListTableViewViewController.swift
//  GoodNews
//
//  Created by 大江祥太郎 on 2021/08/08.
//

//Content Hugging Priority が高いと、コンテンツのサイズを優先する

import Foundation
import UIKit

class NewsListTableViewViewController: UITableViewController {

    fileprivate var articles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup(){
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        //laegeTitle(大)時の文字
        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor:UIColor.white,
             .font : UIFont.boldSystemFont(ofSize: 26.0)
         ]
        
        let urlString =  "https://newsapi.org/v2/top-headlines?country=us&apiKey=07fe9de144f541bca8919b300926ad77"
        
        Webservice().getArticles(with: urlString,completion: { (articles) in
            guard let data = articles else{
                return
            }
            self.articles = data
            
            print(articles![0].title)
            print(articles![0].description)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ArticleTableViewCell else {
            fatalError("ArticleTableViewCell not found")
        }
         cell.titleLabel.text = articles[indexPath.row].title
         cell.descriptionLabel.text = articles[indexPath.row].description

        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = articles[indexPath.row].title
       */
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count 
    }
    
    

    
}
