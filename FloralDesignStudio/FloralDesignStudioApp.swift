//
//  FloralDesignStudioApp.swift
//  FloralDesignStudio
//
//  Created by Jeff Drinkard on 11/26/24.
//

import SwiftUI

@main
struct FloralDesignStudioApp: App {
    @StateObject private var viewModel = FloralDesignViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
    }
}
