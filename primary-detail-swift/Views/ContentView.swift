//
//  ContentView.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct ContentView: View {
    
    /// Load post provider for network and database
    var postProvider: PostProvider = .shared
    
    /// Provides collection of CoreData objects to SwiftUI view
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)])
    private var posts: FetchedResults<Post>
    
    var body: some View {
        /// Start of navigation view
        NavigationView {
            /// Displaying a list of posts from CoreData
            List(posts) { post in
                /// Selecting a post goes to the detail screen
                NavigationLink(destination:
                                PostDetail(post: post)) {
                    PostRow(post: post)
                }
            }
            /// Title of the current screen
            .navigationTitle(title)
            /// Swipe to refresh
            .refreshable {
                await fetchPosts()
            }
            EmptyView()
        }
        /// Fetch posts from network so list isn't empty the first time
        .task {
            await fetchPosts()
        }
        
    }
}

extension ContentView {
    /// Title of the screen.  For now, it is only Posts
    var title: String {
        return "Posts"
    }

    /// Async function to fetch posts from network
    private func fetchPosts() async {
        do {
            try await postProvider.fetchPosts()
        } catch {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
