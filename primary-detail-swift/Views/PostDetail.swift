//
//  PostDetail.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct PostDetail: View {
    var post: Post
    
    var body: some View {
        ScrollView {
            Text(post.title)
                .font(.title)
            Text(post.body)
                .font(.body)
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostDetail_Previews: PreviewProvider {
    static var previews: some View {
        PostDetail(post: posts[0])
    }
}
