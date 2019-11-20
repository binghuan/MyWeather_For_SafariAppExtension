//
//  ContentView.swift
//  MyWeather
//
//  Created by binghuan on 11/20/19.
//  Copyright © 2019 Studio Bing-Huan. All rights reserved.
//

import SwiftUI
import SafariServices.SFSafariApplication

struct ContentView: View {
    var body: some View {
        VStack {
            Image("AppImage")
            Text("My Weather")
            Button(action: {
                SFSafariApplication.showPreferencesForExtension(
                withIdentifier:"com.bh.macos.MyWeather-Extension") {
                    error in
                    if let _ = error {
                        // Insert code to inform the user that something went wrong.
                    }
                }
            }) {
                Text("Open Safari Extension Preferences")
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
