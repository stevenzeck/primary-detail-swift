//
//  PostModelData.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import Foundation
import SwiftUI

let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

class Network: ObservableObject {
    @Published var posts: [Post] = []

    func getPosts() {

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedUsers = try JSONDecoder().decode([Post].self, from: data)
                        self.posts = decodedUsers
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
}
