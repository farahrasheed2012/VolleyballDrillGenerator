import SwiftUI

// MARK: - Drill Detail View

/// Full-screen detail for a single drill: level, description, equipment, source link,
/// and an "Add to Practice Plan" button.
struct DrillDetailView: View {
    @EnvironmentObject var store: DrillStore
    let drill: Drill

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Hero image for the drill
                DrillImageView(drill: drill, mode: .hero)
                    .padding(.horizontal, -16)

                // Skill + Level badges
                HStack(spacing: 10) {
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
                    .font(.headline)

                Text(drill.description)
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                // Equipment
                Text("Equipment")
                    .font(.headline)

                ForEach(drill.equipment, id: \.self) { item in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.green)
                        Text(item)
                            .font(.body)
                    }
                }

                Divider()

                // Source link
                if let url = URL(string: drill.source), !drill.source.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Source")
                            .font(.headline)
                        Link(destination: url) {
                            HStack(spacing: 6) {
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
                    Label(
                        store.isInPlan(drill) ? "Remove from Practice Plan" : "Add to Practice Plan",
                        systemImage: store.isInPlan(drill) ? "minus.circle.fill" : "plus.circle.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(store.isInPlan(drill) ? .red : .orange)
                .controlSize(.large)

                if store.practicePlan.count >= 5 && !store.isInPlan(drill) {
                    Text("Practice plan is full (max 5 drills). Remove one first.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
        }
        .navigationTitle(drill.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.recordViewed(drill)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.toggleFavorite(drill)
                } label: {
                    Image(systemName: store.isFavorite(drill) ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorite(drill) ? .red : .primary)
                }
                .accessibilityLabel(store.isFavorite(drill) ? "Remove from favorites" : "Add to favorites")
            }
        }
    }
}
