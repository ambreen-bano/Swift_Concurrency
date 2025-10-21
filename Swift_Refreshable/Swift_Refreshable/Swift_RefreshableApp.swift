//
//  Swift_RefreshableApp.swift
//  Swift_Refreshable
//
//  Created by Ambreen Bano on 12/10/25.
//

import SwiftUI

@main
struct Swift_RefreshableApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RefreshableView()
            }
        }
    }
}
