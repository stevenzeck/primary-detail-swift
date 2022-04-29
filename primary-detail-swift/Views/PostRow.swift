//
//  PostRow.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct PostRow: View {
    var post: Post

    var body: some View {
        Text(post.title)
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostRow(post: posts[0])
            PostRow(post: posts[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
