//
//  Webservice.swift
//  GoodNews
//
//  Created by 大江祥太郎 on 2021/08/08.
//

import Foundation




class Webservice {
    
    func getArticles(with urlString:String,completion:@escaping ([Article]?) -> ()){
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            //③Give the sessin Task
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
                        
                        
                        print(decodedData.articles[0].description)
                        
                    } catch  {
                        print(String(describing: error))
                        
                    }
                    
                }
            }
            
            //④Start the task
            task.resume()
        }
    }
    /*
     func parseJSON(_ weatherData:Data){
     
     let decoder = JSONDecoder()
     do {
     let decodedData = try decoder.decode(ArticleList.self, from: weatherData)
     
     //print(decodedData)
     
     print(decodedData.articles[0].title)
     
     //print(weather.conditinName)
     
     
     
     } catch  {
     
     
     }
     
     
     }
     */
    
    
    /*
     URLSession.shared.dataTask(with: url) { data, response, error in
     if let error = error{
     print(error.localizedDescription)
     return
     }
     if let data = data{
     
     let articleList = try? JSONDecoder().decode(ArticleList.self,from:data)
     
     if let articleList = articleList {
     print(articleList)
     }
     print(articleList?.articles)
     }
     }.resume()
     }
     
     
     }
     */
}
