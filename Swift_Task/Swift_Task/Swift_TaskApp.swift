//
//  Swift_TaskApp.swift
//  Swift_Task
//
//  Created by Ambreen Bano on 11/10/25.
//

import SwiftUI

@main
struct Swift_TaskApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SwiftTask()
                    .navigationTitle("Task...")
            }
        }
    }
}
