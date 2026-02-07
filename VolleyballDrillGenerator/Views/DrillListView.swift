import SwiftUI

// MARK: - Drill List View

/// Shows all drills grouped by skill category with skill + level filters.
struct DrillListView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedSkill: SkillCategory = .serving
    @State private var selectedLevel: PlayerLevel? = nil  // nil = all levels
    @State private var searchText = ""

    /// Filtered drills based on skill + level + search
    private var filteredDrills: [Drill] {
        var result = store.drills(for: selectedSkill)

        // Filter by level if one is selected
        if let level = selectedLevel {
            result = result.filter { $0.level == level.rawValue }
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

                // Level filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
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
                    Text("\(filteredDrills.count) drills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)

                // Drill list
                List(filteredDrills) { drill in
                    NavigationLink(destination: DrillDetailView(drill: drill)) {
                        DrillRowView(drill: drill)
                    }
                }
                .listStyle(.plain)
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
