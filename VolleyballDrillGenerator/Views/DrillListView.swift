import SwiftUI

// MARK: - Drill List View

/// Shows all drills grouped by skill category with a filter picker.
struct DrillListView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedSkill: SkillCategory = .serving
    @State private var searchText = ""

    /// Filtered drills based on skill + search
    private var filteredDrills: [Drill] {
        let skillDrills = store.drills(for: selectedSkill)
        if searchText.isEmpty { return skillDrills }
        return skillDrills.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
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
                .padding()

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

/// A compact row for use in lists
struct DrillRowView: View {
    let drill: Drill

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(drill.name)
                .font(.headline)

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
