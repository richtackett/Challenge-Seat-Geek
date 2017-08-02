//
//  SearchViewController.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIView!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var events = [EventViewModel]()
    fileprivate lazy var networkService = NetworkService()
    fileprivate var totalCount: Int = 0
    fileprivate var currentPage: Int = 1
    fileprivate let debouncer = Debouncer(interval: 0.3)
    fileprivate let favoritesRepo = FavoritesRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Event Search"
        activityView.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        _setupSearchBar()
        _setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _resetNavBarColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        events = []
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchDetailVC = segue.destination as? SearchDetailViewController,
            let indexPath =  tableView.indexPathForSelectedRow {
            searchDetailVC.event = events[indexPath.row]
            searchDetailVC.indexPath = indexPath
            searchDetailVC.delegate = self
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        _adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        _adjustInsetForKeyboardShow(false, notification: notification)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty == false else {
            _clearTable()
            return
        }
        
        _becomeActive()
        debouncer.callback = {[weak self]() -> Void in
            self?.currentPage = 1
            self?._search(query: searchText, page: 1)
        }
        debouncer.call()
    }
}

//MARK: - UITableViewDataSource and UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath)
        if let searchCell = cell as? SearchTableViewCell {
            events[indexPath.row].isFavorite = favoritesRepo.isEventFavorite(eventID: events[indexPath.row].ID)
            searchCell.populate(event: events[indexPath.row])
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        if (indexPath.row == events.count - 1) && (totalCount != events.count) {
            currentPage = currentPage + 1
            _search(query: searchText, page: currentPage)
        }
    }
}

//MARK: - FavoriteDelegate
extension SearchViewController: FavoriteDelegate {
    func updateTable(indexPath: IndexPath?, isFavorite: Bool) {
        guard let indexPath = indexPath else {
            return
        }
        
        events[indexPath.row].isFavorite = isFavorite
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

//MARK: - Private Helper Methods
fileprivate extension SearchViewController {
    func _setupSearchBar() {
        searchController.searchBar.barTintColor = UIColor.navBarBlue()
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.backgroundImage = nil
        searchController.searchBar.backgroundColor = UIColor.navBarBlue()
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.white
            }
            
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = UIColor.white
            }
        }
    }
    
    func _setupTableView() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 112
        tableView.tableFooterView = UIView()
    }
    
    func _resetNavBarColors() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.barTintColor = UIColor.navBarBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func _search(query: String, page: Int) {
        networkService.sendRequest(query: query, page: page) {[weak self] (result) in
            self?._becomeIdel()
            switch result {
            case .success(let searchResponse):
                self?._handleSuccess(searchResponse: searchResponse)
            case .failure:
                self?._handleError()
            }
        }
    }
    
    func _handleSuccess(searchResponse: SearchResponse) {
        totalCount = searchResponse.totalCount
        
        if currentPage == 1 {
            events = searchResponse.events
        } else {
            events += searchResponse.events
        }
        
        DispatchQueue.main.async {
            self._displayCorrectTableViewFooter()
            self.tableView.reloadData()
        }
    }
    
    func _handleError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func _becomeActive() {
        activityView.isHidden = false
    }
    
    func _becomeIdel() {
        DispatchQueue.main.async {
            self.activityView.isHidden = true
        }
    }
    
    func _clearTable() {
        events = []
        totalCount = 0
        _displayCorrectTableViewFooter()
        tableView.reloadData()
    }
    
    func _displayCorrectTableViewFooter() {
        if totalCount == events.count {
            tableView.tableFooterView = UIView()
        } else {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60)
            spinner.backgroundColor = UIColor.white
            self.tableView.tableFooterView = spinner
        }
    }
    
    func _adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        guard let value = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20)
        if show {
            tableView.contentInset.bottom = adjustmentHeight
            tableView.scrollIndicatorInsets.bottom = adjustmentHeight
            
        } else {
            tableView.contentInset.bottom = 0
            tableView.scrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - Extension for Color
extension UIColor {
    static func navBarBlue() -> UIColor {
        return UIColor(colorLiteralRed: 26.0/255.0, green: 48.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    }
}
