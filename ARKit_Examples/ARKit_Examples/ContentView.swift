//
//  ContentView.swift
//  ARKit_Examples
//
//  Created by Jacob Van Order on 12/10/22.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case SceneKit
        case RealityKit
    }
    
    @State var selectedTab: Tab = .SceneKit
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SceneKitRepresentableView()
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
                .tabItem {
                    Label("SceneKit", systemImage: "cube.transparent")
                }
                .tag(Tab.SceneKit)
            RealityKitRepresentableView()
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
                .tabItem {
                    Label("RealityKit", systemImage: "cube")
                }
                .tag(Tab.RealityKit)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
