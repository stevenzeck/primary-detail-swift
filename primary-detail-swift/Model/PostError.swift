//
//  PostError.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 5/2/22.
//

import Foundation

enum PostError: Error {
    case unexpectedError
    case PostsError(error: Error)
}
