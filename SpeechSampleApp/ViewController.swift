//
//  ViewController.swift
//  SpeechSampleApp
//
//  Created by SpotHeroMatt on 9/27/16.
//  Copyright © 2016 Matthew Reed. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ViewController: UIViewController {
    var urlComponents: URLComponents = {
        var _urlComponents = URLComponents(string: "http://api.giphy.com/v1/gifs/search")!
        _urlComponents.queryItems = [URLQueryItem(name: "api_key", value: "dc6zaTOxFJmzC")]
        return _urlComponents
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [[String: AnyObject]]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! VoiceSearchViewController
        vc.completion = { text in
            self.searchForGifs(text: text)
        }
    }
    
    func searchForGifs(text: String) {
        let lowercased = text.lowercased()
        let query = lowercased.replacingOccurrences(of: " ", with: "+")
        
        urlComponents.queryItems?.append(URLQueryItem(name: "q", value: query))
        
        guard let url = urlComponents.url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject], let data = json?["data"] as? [[String: AnyObject]] {
                print(json)
                DispatchQueue.main.async {
                    self.dataSource = data
                }
            }
            
            }.resume()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        searchForGifs(text: text)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GifTableViewCell
        
        let dict = dataSource[indexPath.row]
        let images = dict["images"] as! [String: AnyObject]
        let original = images["original"] as! [String: AnyObject]
        let urlString = original["url"] as! String
        let url = URL(string: urlString)!
        cell.gifImageView.animatedImage = nil
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let image = FLAnimatedImage(animatedGIFData: data)
            cell.gifImageView.animatedImage = image
        }.resume()
        
        return cell
    }
}
