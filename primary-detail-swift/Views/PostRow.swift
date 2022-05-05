//
//  PostRow.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct PostRow: View {
    /// Observe the post object, so it changes from bold to regular font after updating CoreData
    @ObservedObject var post: Post
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                /// If post is read, font is normal.  If unread, it's bold
                Text(post.title)
                    .font(post.read ? .none : .body.bold())
            }
        }
        .padding(.vertical, 8)
    }
}

//struct PostRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            PostRow(post: posts[0])
//            PostRow(post: posts[1])
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//    }
//}
