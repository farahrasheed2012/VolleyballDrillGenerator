import SwiftUI

// MARK: - Drill Detail View

/// Full-screen detail for a single drill: level, description, equipment, source link,
/// and an "Add to Practice Plan" button.
struct DrillDetailView: View {
    @EnvironmentObject var store: DrillStore
    let drill: Drill

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Hero image for the drill
                DrillImageView(drill: drill, mode: .hero)
                    .padding(.horizontal, -16) // bleed to edges

                // Skill + Level badges
                HStack(spacing: 8) {
                    if let cat = drill.skillCategory {
                        HStack {
                            Image(systemName: cat.icon)
                            Text(cat.rawValue)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(cat.color, in: Capsule())
                    }

                    if let lvl = drill.playerLevel {
                        HStack(spacing: 4) {
                            Image(systemName: lvl.icon)
                            Text(lvl.rawValue)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(lvl.color, in: Capsule())
                    }
                }

                // Description
                Text("Instructions")
                    .font(.title3.bold())

                Text(drill.description)
                    .font(.body)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                // Equipment
                Text("Equipment")
                    .font(.title3.bold())

                ForEach(drill.equipment, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(item)
                    }
                    .font(.body)
                }

                Divider()

                // Source link
                if let url = URL(string: drill.source), !drill.source.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Source")
                            .font(.title3.bold())
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "link")
                                Text("View Original Source")
                            }
                            .font(.subheadline)
                        }
                    }
                }

                Divider()

                // Add / Remove from Practice Plan
                Button {
                    store.toggleInPlan(drill)
                } label: {
                    HStack {
                        Image(systemName: store.isInPlan(drill)
                              ? "minus.circle.fill"
                              : "plus.circle.fill")
                        Text(store.isInPlan(drill)
                             ? "Remove from Practice Plan"
                             : "Add to Practice Plan")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(store.isInPlan(drill) ? Color.red : Color.orange,
                                in: RoundedRectangle(cornerRadius: 14))
                }

                if store.practicePlan.count >= 5 && !store.isInPlan(drill) {
                    Text("Practice plan is full (max 5 drills). Remove one first.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(drill.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // Skill color now comes from SkillCategory.color
}
