//
//  SearchTableViewCell.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import UIKit
import Kingfisher

final class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func populate(event: EventViewModel) {
        titleLabel.text = event.title
        locationLabel.text = event.location
        timeLabel.text = event.when
        
        if let imageURL = event.imageURL {
            eventImageView.kf.setImage(with: imageURL)
        } else {
            eventImageView.image = nil
        }
        
        if event.isFavorite == true {
            favoriteImageView.isHidden = false
        } else {
            favoriteImageView.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventImageView.layer.cornerRadius = 4.0
        eventImageView.clipsToBounds = true
    }
}
