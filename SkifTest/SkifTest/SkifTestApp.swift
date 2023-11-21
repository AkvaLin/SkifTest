//
//  SkifTestApp.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import SwiftUI
import GoogleMaps

@main
struct SkifTestApp: App {
    
    init() {
        GMSServices.provideAPIKey("KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
