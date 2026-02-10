import SwiftUI

// MARK: - Drill Card View

/// A compact card that summarises a drill: thumbnail, name, skill badge, level badge, and equipment.
struct DrillCardView: View {
    let drill: Drill

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            DrillImageView(drill: drill, mode: .thumbnail)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(drill.name)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

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

                    if let cat = drill.skillCategory {
                        Text(cat.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundColor(.white)
                            .background(cat.color, in: Capsule())
                    }
                }

                Text(drill.description.components(separatedBy: "\n").first ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if !drill.equipment.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "sportscourt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(drill.equipment.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
