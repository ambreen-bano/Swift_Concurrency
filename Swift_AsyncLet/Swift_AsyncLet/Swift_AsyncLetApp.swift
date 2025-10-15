//
//  Swift_AsyncLetApp.swift
//  Swift_AsyncLet
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

@main
struct Swift_AsyncLetApp: App {
    var body: some Scene {
        WindowGroup {
            AsyncAwaitSequentialCallsView()
        //    AsyncAwaitConcurrentCallsView()
        //    AsyncLetConcurrentCallsView()
        }
    }
}
