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
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Recently viewed (when available)
                if !store.recentlyViewedDrills.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recently viewed")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.recentlyViewedDrills.prefix(5)) { drill in
                                    NavigationLink(destination: DrillDetailView(drill: drill)) {
                                        Text(drill.name)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(Color(.tertiarySystemFill), in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 8)
                }

                // Level filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Favorites chip
                        Button {
                            withAnimation { showFavoritesOnly.toggle() }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.caption)
                                Text("Favorites")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(showFavoritesOnly ? .white : .primary)
                            .background(showFavoritesOnly ? Color.pink : Color(.tertiarySystemFill),
                                        in: Capsule())
                        }
                        .buttonStyle(.plain)

                        // "All Levels" chip
                        Button {
                            withAnimation { selectedLevel = nil }
                        } label: {
                            Text("All Levels")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .foregroundColor(selectedLevel == nil ? .white : .primary)
                                .background(selectedLevel == nil ? Color.orange : Color(.tertiarySystemFill),
                                            in: Capsule())
                        }
                        .buttonStyle(.plain)

                        ForEach(PlayerLevel.allCases) { level in
                            Button {
                                withAnimation { selectedLevel = level }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: level.icon)
                                        .font(.caption)
                                    Text(level.shortLabel)
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .foregroundColor(selectedLevel == level ? .white : .primary)
                                .background(selectedLevel == level ? level.color : Color(.tertiarySystemFill),
                                            in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                // Drill count
                HStack {
                    Text("\(filteredDrills.count) drill\(filteredDrills.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

                // Drill list or empty state
                if filteredDrills.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                        Text("No drills match")
                            .font(.title3.weight(.semibold))
                        Text("Try a different skill, level, or search term.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Clear filters") {
                            searchText = ""
                            selectedLevel = nil
                        }
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                } else {
                    List(filteredDrills) { drill in
                        NavigationLink(destination: DrillDetailView(drill: drill)) {
                            DrillRowView(drill: drill)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("All Drills")
            .background(Color(.systemGroupedBackground))
            .searchable(text: $searchText, prompt: "Search drills...")
        }
    }
}

// MARK: - Drill Row View

/// A compact row for use in lists, showing name, level badge, and equipment
struct DrillRowView: View {
    let drill: Drill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(drill.name)
                    .font(.headline)

                Spacer()

                if let lvl = drill.playerLevel {
                    HStack(spacing: 3) {
                        Image(systemName: lvl.icon)
                            .font(.caption2)
                        Text(lvl.shortLabel)
                            .font(.caption2.weight(.semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.white)
                    .background(lvl.color, in: Capsule())
                }
            }

            Text(drill.description.components(separatedBy: "\n").first ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "sportscourt")
                    .font(.caption)
                Text(drill.equipment.joined(separator: ", "))
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
