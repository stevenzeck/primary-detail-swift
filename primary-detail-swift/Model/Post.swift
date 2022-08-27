//
//  Post.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import CoreData

/// Class must be the same as the entity in the Posts CoreData
/// Implementing behavior of CoreData model, so extend NSManagedObject
/// Using Identifiable protocol, so we must have an id property
class Post: NSManagedObject, Identifiable {
    
    /// id property, required for Identifiable, but also present in posts API
    @NSManaged var id: Int64
    /// userId of the post
    @NSManaged var userId: Int64
    /// Title of the post
    @NSManaged var title: String
    /// Body of the post
    @NSManaged var body: String
    /// Whether the post is read or not
    @NSManaged var read: Bool
    
    ///
    func update(from postProperties: PostProperties) throws {
        let dictionary = postProperties.dictionaryValue
        guard let newId = dictionary["id"] as? Int64,
              let newUserId = dictionary["userId"] as? Int64,
              let newTitle = dictionary["title"] as? String,
              let newBody = dictionary["body"] as? String,
              let newRead = dictionary["read"] as? Bool
        else {
            throw PostError.unexpectedError
        }
        
        id = newId
        userId = newUserId
        title = newTitle
        body = newBody
        read = newRead
    }
}

extension Post {
    
    /// A post for use with canvas previews
    static var preview: Post {
        let posts = Post.makePreviews(count: 1)
        return posts[0]
    }

    @discardableResult
    static func makePreviews(count: Int) -> [Post] {
        var posts = [Post]()
        let viewContext = PostProvider.preview.container.viewContext
        for index in 0..<count {
            let post = Post(context: viewContext)
            post.id = Int64(index)
            post.userId = 1
            post.title = "The title"
            post.body = "The body"
            post.read = false
            posts.append(post)
        }
        return posts
    }
}

/// Decodable from JSON
struct PostProperties: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case body
        case read
    }
    
    let id: Int
    let userId: Int
    let title: String
    let body: String
    let read: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        /// Each of the raw values from JSON, forKey value must match JSON key
        let rawId = try? values.decode(Int.self, forKey: .id)
        let rawUserId = try? values.decode(Int.self, forKey: .userId)
        let rawTitle = try? values.decode(String.self, forKey: .title)
        let rawBody = try? values.decode(String.self, forKey: .body)
        /// read is not in the JSON, and the default is false
        let read = false
        
        guard let id = rawId,
              let userId = rawUserId,
              let title = rawTitle,
              let body = rawBody
        else {
            throw PostError.unexpectedError
        }
        
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.read = read
    }
    
    var dictionaryValue: [String: Any] {
        [
            "id": id,
            "userId": userId,
            "title": title,
            "body": body,
            "read": read
        ]
    }
}
