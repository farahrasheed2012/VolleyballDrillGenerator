import SwiftUI

// MARK: - Drill Card View

/// A compact card that summarises a drill: thumbnail, name, skill badge, level badge, and equipment.
struct DrillCardView: View {
    let drill: Drill

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail image on the leading edge
            DrillImageView(drill: drill, mode: .thumbnail)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 10) {
                // Name & badges row
                HStack {
                    Text(drill.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Spacer()

                    // Level badge
                    if let lvl = drill.playerLevel {
                        HStack(spacing: 3) {
                            Image(systemName: lvl.icon)
                                .font(.caption2)
                            Text(lvl.shortLabel)
                                .font(.caption2.bold())
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .foregroundColor(.white)
                        .background(lvl.color, in: Capsule())
                    }

                    // Skill badge
                    if let cat = drill.skillCategory {
                        Text(cat.rawValue)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundColor(.white)
                            .background(cat.color, in: Capsule())
                    }
                }

                // Short preview of description (first line)
                Text(drill.description.components(separatedBy: "\n").first ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Equipment tags
                if !drill.equipment.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "sportscourt")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(drill.equipment.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
    }
}
