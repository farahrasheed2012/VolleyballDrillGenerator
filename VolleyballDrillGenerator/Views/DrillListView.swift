import SwiftUI

// MARK: - Drill List View

/// Shows all drills grouped by skill category with skill + level filters.
struct DrillListView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedSkill: SkillCategory = .serving
    @State private var selectedLevel: PlayerLevel? = nil  // nil = all levels
    @State private var showFavoritesOnly = false
    @State private var searchText = ""

    /// Filtered drills based on skill + level + search + favorites
    private var filteredDrills: [Drill] {
        var result = store.drills(for: selectedSkill)

        // Filter by level if one is selected
        if let level = selectedLevel {
            result = result.filter { $0.level == level.rawValue }
        }

        // Filter by favorites when "Favorites" is on
        if showFavoritesOnly {
            result = result.filter { store.favoriteDrillNames.contains($0.name) }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Skill category picker
                Picker("Skill", selection: $selectedSkill) {
                    ForEach(SkillCategory.allCases) { skill in
                        Text(skill.rawValue).tag(skill)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                // Recently viewed (when available)
                if !store.recentlyViewedDrills.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recently viewed")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.recentlyViewedDrills.prefix(5)) { drill in
                                    NavigationLink(destination: DrillDetailView(drill: drill)) {
                                        Text(drill.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color(.systemGray5), in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 4)
                }

                // Level filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Favorites chip
                        Button {
                            withAnimation { showFavoritesOnly.toggle() }
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.caption2)
                                Text("Favorites")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .foregroundColor(showFavoritesOnly ? .white : .primary)
                            .background(showFavoritesOnly ? Color.pink : Color(.systemGray5),
                                        in: Capsule())
                        }

                        // "All Levels" chip
                        Button {
                            withAnimation { selectedLevel = nil }
                        } label: {
                            Text("All Levels")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundColor(selectedLevel == nil ? .white : .primary)
                                .background(selectedLevel == nil ? Color.orange : Color(.systemGray5),
                                            in: Capsule())
                        }

                        ForEach(PlayerLevel.allCases) { level in
                            Button {
                                withAnimation { selectedLevel = level }
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: level.icon)
                                        .font(.caption2)
                                    Text(level.shortLabel)
                                        .font(.caption.bold())
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundColor(selectedLevel == level ? .white : .primary)
                                .background(selectedLevel == level ? level.color : Color(.systemGray5),
                                            in: Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Drill count
                HStack {
                    Text("\(filteredDrills.count) drill\(filteredDrills.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)

                // Drill list or empty state
                if filteredDrills.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.orange.opacity(0.6))
                        Text("No drills match")
                            .font(.headline)
                        Text("Try a different skill, level, or search term.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Clear filters") {
                            searchText = ""
                            selectedLevel = nil
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    List(filteredDrills) { drill in
                        NavigationLink(destination: DrillDetailView(drill: drill)) {
                            DrillRowView(drill: drill)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("All Drills")
            .searchable(text: $searchText, prompt: "Search drills...")
        }
    }
}

// MARK: - Drill Row View

/// A compact row for use in lists, showing name, level badge, and equipment
struct DrillRowView: View {
    let drill: Drill

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(drill.name)
                    .font(.headline)

                Spacer()

                // Level badge
                if let lvl = drill.playerLevel {
                    HStack(spacing: 3) {
                        Image(systemName: lvl.icon)
                            .font(.caption2)
                        Text(lvl.shortLabel)
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .foregroundColor(.white)
                    .background(lvl.color, in: Capsule())
                }
            }

            Text(drill.description.components(separatedBy: "\n").first ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "sportscourt")
                    .font(.caption2)
                Text(drill.equipment.joined(separator: ", "))
                    .font(.caption2)
            }
            .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}
