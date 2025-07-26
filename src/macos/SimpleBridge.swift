import SwiftUI

@main
struct SimpleBridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Bridge!")
                .font(.largeTitle)
                .padding()
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
}