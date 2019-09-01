//
//  ViewController.swift
//  NewsAppPeCode
//
//  Created by Horbach on 8/26/19.
//  Copyright © 2019 Horbach. All rights reserved.
//"https://newsapi.org/v2/top-headlines?sources=\(provider)&apiKey=59324066ae8c402499dd186b8b35d6d0"




import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var articles : [Article]? = []
    var searchData: [Article]? = []
    var source = "techcrunch"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchArticles(fromSource: source)
        setUpSearchBar()
       
    }
    

    
    func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty  else {
            searchData = articles
            tableView.reloadData()
            return
        }
         searchData = articles?.filter({ article -> Bool in
            ((article.headline?.lowercased().contains(searchText.lowercased()))!)
        })
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchData = articles
        searchBar.text = ""
        hideKeyboard()
        tableView.reloadData()
    }
    

    func  fetchArticles( fromSource provider: String) {
        let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v2/top-headlines?sources=\(provider)&apiKey=59324066ae8c402499dd186b8b35d6d0")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            if error != nil {
                print(error as Any)
                return
            }
            self.articles = [Article]()
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let articlesFromJson = json["articles"] as? [[String: AnyObject]] {
                    for articleFromJson in articlesFromJson {
                        let article = Article()
                        if let title = articleFromJson["title"] as? String, let author = articleFromJson ["author"] as? String,let desc = articleFromJson ["description"] as? String, let url = articleFromJson["url"] as? String,let publishedAt = articleFromJson["publishedAt"] as? String, let urlToImage  = articleFromJson["urlToImage"] as? String {
                            
                            article.author = author
                            article.desc = desc
                            article.headline = title
                            article.url = url
                            article.imageUrl = urlToImage
                            article.publishedAt = publishedAt
                        }
                        self.articles?.append(article)
                        self.searchData = self.articles
                    }
                }
                DispatchQueue.main.async {
                     self.tableView.reloadData()
                }
            }catch let error{
                print(error)
                
            }
            
        }
           task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        
        cell.titleLabel.text = self.searchData?[indexPath.item].headline
        cell.descLabel.text = self.searchData?[indexPath.item].desc
        cell.authorLabel.text = self.searchData?[indexPath.item].author
        cell.publishedLabel.text = self.articles?[indexPath.item].publishedAt
        cell.imgView.downloadImage(from: ((self.articles?[indexPath.item].imageUrl)!)!)
        
        
        
        return cell

    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData!.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebViewViewController
        webVC.url = self.searchData?[indexPath.item].url
        self.present(webVC, animated: true, completion: nil)
    }
    let menuManager = MenuManager()
    
    @IBAction func menuPressed(_ sender: Any) {
        menuManager.openMenu()
        menuManager.mainVC = self
    }
    
}
extension UIImageView {
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response, error) in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
                self.image.sizeToFit()
            }
            
        }
        task.resume()
    }
}
extension UIViewController {
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

