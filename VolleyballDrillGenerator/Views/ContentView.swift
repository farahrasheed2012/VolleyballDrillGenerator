import SwiftUI

// MARK: - Content View (Main Screen)

/// Root view with tab navigation: Generator, Drill List, Practice Plan
struct ContentView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Generator + Drill of the Day
            GeneratorView()
                .tabItem {
                    Label("Generator", systemImage: "dice.fill")
                }
                .tag(0)

            // Tab 2: Browse all drills
            DrillListView()
                .tabItem {
                    Label("All Drills", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            // Tab 3: Build a practice plan
            PracticePlanView()
                .tabItem {
                    Label("Practice Plan", systemImage: "calendar")
                }
                .tag(2)
        }
        .accentColor(.orange)
    }
}
