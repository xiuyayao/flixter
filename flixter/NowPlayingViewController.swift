//
//  NowPlayingViewController.swift
//  flixter
//
//  Created by Xiuya Yao on 6/21/17.
//  Copyright © 2017 Xiuya Yao. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=b0dc2f9b663ecf33aed9b648055a6c7f")!
        // Above statement returns an optional url, so bang (!) added at end to force unwrapping
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        // reloadIgnoringLocalCacheData means our network request is always going to pukll from network even if data is in cache
        // 10 is time in seconds
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // When our network request returns, it'll jump back on our main
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This code below will run with network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                // got JSON data back and now parse it
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                // try! force unwraps it
                // will crash is there's an error
                // cast into Swift dictionary
                // print(dataDictionary)
                let movies = dataDictionary["results"] as! [[String: Any]]
                // test print code
                /*
                for movie in movies {
                    let title = movie["title"] as! String
                    print(title)
                }
                */
                self.movies = movies
                // after network request comes back
                // will load blank table view on phone screen if the line below not included
                self.tableView.reloadData()
            }
        }
        task.resume()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Hey go find thing with the identifier MovieCell and cast it as MovieCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
