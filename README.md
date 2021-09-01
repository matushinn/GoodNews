# GoodNews

# はじめに 
SwiftでNews APIを使ってニュースアプリを作ってみたいと思います。
初心者にもわかりやすく、AutoLayoutの設定、デザインパターン、コードの可読性もしっかり守っているので、APIの入門記事としてはぴったりかなと。
では始めていきます。ぜひ最後までご覧ください。

## UIの設計

このように配置していきます。

![スクリーンショット 2021-09-01 20.39.33.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/12861ba6-f47a-ffb7-3221-456c4fde786f.png)
NewsListTableViewControllerからDetailViewControllerまでのsegueのidentifierに"toWeb"とつけてください。


ArticleTableViewCellを作り、IBOutlet接続します。

```swift:ArticleTableViewCell.swift
import Foundation
import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var urlImageView: UIImageView!
    
}
```

## 全体設計
UIができた後に、今回のアプリの設計を行なっていく。
![スクリーンショット 2021-09-01 20.57.52.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/8344b4cf-f82b-893e-f654-1b5a7365e5c5.png)



![スクリーンショット 2021-09-01 20.56.00.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/a9f8adb0-417e-d790-4caa-0d694ea43bf4.png)

## APIの取得
まず、APIの取得からやっていきたいと思います。
[NewsAPI](https://newsapi.org/)を使います。
操作は以下。

![スクリーンショット 2021-09-01 21.00.05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/e0316928-365c-efab-03f7-802c7c383709.png)

ログインをする、またアカウントがない場合は新規アカウント登録を行う。
それができたら、ここでAPIKeyを取得する。

![スクリーンショット 2021-09-01 21.00.58.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/0d0a1cc9-6282-f6b8-bb55-e08e531b7f0b.png)


そしてこのようにAPIを叩くと、JSONデータを変換してくれます。

![スクリーンショット 2021-09-01 21.05.36.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/6cc4fbda-cc84-4962-f9e2-1341968cbdf0.png)
これらのデータをうまく使い今回はアプリを作成していきます。


## Webservice
今回のAPIにおいてのロジックを管理するWebserviceを書いていきます。

```swift:Webservice.swift
import Foundation

class Webservice {
    
    func getArticles(with urlString:String,completion:@escaping ([Article]?) -> ()){
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    
                    completion(nil)
                }
                
                if let safeData = data {
                    // print(response)
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(ArticleList.self, from: safeData)
                        
                        completion(decodedData.articles)
                        //プリントをしながら中身を確認する
                        //print(decodedData.articles[0].description)
                        
                    } catch  {
                        print(String(describing: error))
                        
                    }
                }
            }
            
            task.resume()
        }
    }
}


```

## Article
レスポンスしたデータをデコードするためのArticleを作成していきます。

```swift:Article.swift
import Foundation

struct ArticleList: Codable {
    let articles: [Article]
}

struct Article: Codable{
    let title:String
    let description:String
    let urlToImage:String
    let url:String
}
```

## ViewController
最後に取得したデータをViewに反映させる、またUITableViewの操作のためにViewControllerを作っていきます。
その前に画像のキャッシュのために便利な[SDWebImage](https://github.com/SDWebImage/SDWebImage)というライブラリを使いたいと思います。
SDWebImageの詳しい説明、導入の仕方などは[これら](https://qiita.com/hcrane/items/422811dfc18ae919f8a4)の記事を見るとわかると思います。

```swift:NewsListTableViewController
import Foundation
import UIKit
import SDWebImage

class NewsListTableViewViewController: UITableViewController{

    fileprivate var articles: [Article] = []

    var urlArticle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup(){
        
        //ここにAPIKeyを挿入する
        let urlString =  "https://newsapi.org/v2/top-headlines?country=us&apiKey=[APIKey]"
        
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
        
        cell.urlImageView.sd_setImage(with: URL(string: articles[indexPath.row].urlToImage), completed: nil)
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.urlArticle = articles[indexPath.row].url
        
        self.performSegue(withIdentifier: "toWeb", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWeb" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.urlString = self.urlArticle
        }
    }
}


```

そして最後はクリックした記事を閲覧させるためにWKWebViewを使っていきたいと思います。

```swift:DetailViewController
import UIKit
import WebKit

class DetailViewController: UIViewController , WKUIDelegate{
    
    var webView: WKWebView!

    var urlString = ""
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}

```

WKWebViewの処理は[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)のドキュメントを確認しながら学んでください。

完成形は[こちら](https://github.com/matushinn/GoodNews)を参照してください。
指摘点がありましたら、コメントでもよろしくお願いします。



