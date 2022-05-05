//
//  primary_detail_swiftApp.swift
//  primary-detail-swift
//
//  Created by Steven Zeck on 4/27/22.
//

import SwiftUI

@main
struct primary_detail_swiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PostProvider.shared.container.viewContext)
        }
    }
}
