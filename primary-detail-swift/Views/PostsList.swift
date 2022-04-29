//
//  ListScreen.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

struct PostsList: View {
    @EnvironmentObject var network: Network
    var body: some View {
        NavigationView {
            List(network.posts) { post in
                NavigationLink {
                    PostDetail(post: post)
                } label: {
                    PostRow(post: post)
                }
            }
            .navigationTitle("Posts")
        }
        .onAppear {
            network.getPosts()
        }
    }
}

struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
            .environmentObject(Network())
    }
}
