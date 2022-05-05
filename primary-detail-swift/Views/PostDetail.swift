//
//  PostDetail.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct PostDetail: View {
    /// Post object being used, passed from PostDetail in the NavigationLink in ContentView
    var post: Post
    /// viewContext for updating the post in CoreData
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        /// Displaying the title and body of the post
        ScrollView {
            Text(post.title)
                .font(.title)
            Text(post.body)
                .font(.body)
        }
        /// Title of the screen
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
        /// Update CoreData to mark post as read as soon as this screen is rendered
        .task {
            markPostRead(post: post)
        }
    }
}

extension PostDetail {
    /// Update CoreData and mark read as true
    private func markPostRead(post: Post) {
        viewContext.performAndWait {
            post.read = true
            /// Probably not great that it's not handling an error here
            try? viewContext.save()
        }
    }
}

//struct PostDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PostDetail(post: posts[0])
//    }
//}
