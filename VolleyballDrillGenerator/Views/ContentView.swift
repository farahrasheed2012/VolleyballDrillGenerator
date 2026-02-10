import SwiftUI

// MARK: - Content View (Main Screen)

/// Root view with tab navigation: Generator, Drill List, Practice Plan
struct ContentView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if let error = store.loadError {
                loadErrorView(message: error)
            } else {
                TabView(selection: $selectedTab) {
                    GeneratorView()
                        .tabItem { Label("Generator", systemImage: "dice.fill") }
                        .tag(0)
                        .accessibilityLabel("Generator")
                        .accessibilityHint("Generate random drills by skill and level")

                    DrillListView()
                        .tabItem { Label("All Drills", systemImage: "list.bullet.rectangle") }
                        .tag(1)
                        .accessibilityLabel("All Drills")
                        .accessibilityHint("Browse and search all drills")

                    PracticePlanView()
                        .tabItem { Label("Practice Plan", systemImage: "calendar") }
                        .tag(2)
                        .accessibilityLabel("Practice Plan")
                        .accessibilityHint("View and edit your practice session")
                }
                .accentColor(.orange)
            }
        }
    }

    private func loadErrorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Retry") {
                store.retryLoadDrills()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.orange, in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
