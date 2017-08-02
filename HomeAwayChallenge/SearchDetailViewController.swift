//
//  SearchDetailViewController.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import UIKit

protocol FavoriteDelegate: class {
    func updateTable(indexPath: IndexPath?, isFavorite: Bool)
}

final class SearchDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venuLabel: UILabel!
    var event: EventViewModel?
    var indexPath: IndexPath?
    weak var delegate: FavoriteDelegate?
    fileprivate let favoritesRepo = FavoritesRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _makeFavoriteButton()
        _setupNavBar()
        _populate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        event = nil
    }
    
    func heartButtonTap() {
        guard var event = event else {
            return
        }
        
        event.isFavorite = !event.isFavorite
        self.event = event
        _makeFavoriteButton()
        favoritesRepo.markAsFavorite(eventID: event.ID)
        delegate?.updateTable(indexPath: indexPath, isFavorite: event.isFavorite)
    }
}

//MARK: - Private Helper Methods
fileprivate extension SearchDetailViewController {
    func _populate() {
        dateLabel.text = event?.when
        venuLabel.text = event?.location
        imageView.layer.cornerRadius = 4.0
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: event?.imageURL)
    }
    
    func _makeFavoriteButton() {
        let imageName: String = event?.isFavorite == true ? "solidHeart" : "heart"
        let buttonImage = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        let buttonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(heartButtonTap))
        navigationItem.setRightBarButton(buttonItem, animated: true)
    }
    
    func _setupNavBar() {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.title = event?.title
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
    }
}
