//
//  EventViewModel.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 7/31/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation

struct SearchResponse {
    var totalCount = 0
    var events = [EventViewModel]()
}

struct EventViewModel {
    var ID: Int64 = 0
    var title: String?
    var when: String?
    var location: String?
    var isFavorite = false
    var imageURL: URL?
}
