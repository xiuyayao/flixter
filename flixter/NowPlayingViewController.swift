//
//  NowPlayingViewController.swift
//  flixter
//
//  Created by Xiuya Yao on 6/21/17.
//  Copyright © 2017 Xiuya Yao. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    var alertController: UIAlertController!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // activityIndicator outlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [[String: Any]] = []
    var moviesCopy: [[String: Any]] = []
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        
        // start activityIndicator
        activityIndicator.startAnimating()
        
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        
        // Set rowHeight and estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        alertController = UIAlertController(title: "Cannot get movies", message: "Offline", preferredStyle: .alert)
        
        // create a try again action
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view
            self.fetchMovies()
        }
        // add the cancel action to the alertController
        alertController.addAction(tryAgainAction)
        
        /*
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
        Thread.sleep(forTimeInterval: 3)
        activityIndicator.stopAnimating()
        */
        
        refreshControl = UIRefreshControl()
        
        // If it had an event, who is it going to notify?
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        fetchMovies()
        // Do any additional setup after loading the view.
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    func fetchMovies() {
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
                self.present(self.alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
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
                self.moviesCopy = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            // stop activityIndicator
            self.activityIndicator.stopAnimating()
        }
        task.resume()
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        movies = searchText.isEmpty ? moviesCopy : moviesCopy.filter { (movie: [String: Any]) -> Bool in
            
            return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
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
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.powerImageView.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
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
