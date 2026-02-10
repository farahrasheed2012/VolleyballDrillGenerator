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
                Picker("Skill", selection: $selectedSkill) {
                    ForEach(SkillCategory.allCases) { skill in
                        Text(skill.rawValue).tag(skill)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 4)

                if !store.recentlyViewedDrills.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recently viewed")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(store.recentlyViewedDrills.prefix(5)) { drill in
                                    NavigationLink(destination: DrillDetailView(drill: drill)) {
                                        Text(drill.name)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 12)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
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
                            .background(showFavoritesOnly ? Color.blue : Color(.tertiarySystemFill),
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
                                .background(selectedLevel == nil ? Color.blue : Color(.tertiarySystemFill),
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
                                .background(selectedLevel == level ? Color.blue : Color(.tertiarySystemFill),
                                            in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                HStack {
                    Text("\(filteredDrills.count) drill\(filteredDrills.count == 1 ? "" : "s")")
                        .font(.footnote)
                        .foregroundColor(Color(.tertiaryLabel))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                if filteredDrills.isEmpty {
                    VStack(spacing: 24) {
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
                            .padding(.horizontal, 40)
                        Button("Clear filters") {
                            searchText = ""
                            selectedLevel = nil
                        }
                        .font(.subheadline.weight(.medium))
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 56)
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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(drill.name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)

                Spacer(minLength: 8)

                if let lvl = drill.playerLevel {
                    HStack(spacing: 4) {
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
            .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 12)
    }
}
