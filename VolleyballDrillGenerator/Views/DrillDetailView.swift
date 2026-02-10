import SwiftUI

// MARK: - Drill Detail View

/// Full-screen detail for a single drill: level, description, equipment, source link,
/// and an "Add to Practice Plan" button.
struct DrillDetailView: View {
    @EnvironmentObject var store: DrillStore
    let drill: Drill

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                DrillImageView(drill: drill, mode: .hero)
                    .padding(.horizontal, -20)

                HStack(spacing: 10) {
                    if let cat = drill.skillCategory {
                        HStack(spacing: 4) {
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

                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(drill.description)
                        .font(.body)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Equipment")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                    ForEach(drill.equipment, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .foregroundColor(.green)
                            Text(item)
                                .font(.body)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

                if let url = URL(string: drill.source), !drill.source.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Source")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                Text("View Original Source")
                                    .font(.body)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    store.toggleInPlan(drill)
                } label: {
                    Label(
                        store.isInPlan(drill) ? "Remove from Practice Plan" : "Add to Practice Plan",
                        systemImage: store.isInPlan(drill) ? "minus.circle.fill" : "plus.circle.fill"
                    )
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(store.isInPlan(drill) ? .red : .blue)
                .controlSize(.regular)

                if store.practicePlan.count >= 5 && !store.isInPlan(drill) {
                    Text("Practice plan is full (max 5 drills). Remove one first.")
                        .font(.footnote)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
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
                        .foregroundColor(store.isFavorite(drill) ? .blue : .primary)
                }
                .accessibilityLabel(store.isFavorite(drill) ? "Remove from favorites" : "Add to favorites")
            }
        }
    }
}
