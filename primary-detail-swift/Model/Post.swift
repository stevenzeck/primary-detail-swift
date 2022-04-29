//
//  Post.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import Foundation

struct Post: Identifiable, Codable {
    var id: Int
    var userId: Int
    var title: String
    var body: String
    var read: Bool?
}
