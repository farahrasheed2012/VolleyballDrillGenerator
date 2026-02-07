import SwiftUI

@main
struct VolleyballDrillGeneratorApp: App {
    @StateObject private var store = DrillStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
