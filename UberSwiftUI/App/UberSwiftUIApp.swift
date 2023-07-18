//
//  UberSwiftUIApp.swift
//  UberSwiftUI
//
//  Created by george kaimoottil on 18/07/23.
//

import SwiftUI

@main
struct UberSwiftUIApp: App {
    @StateObject var locationViewModel = LocationSearchViewModel()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationViewModel)
        }
    }
}
