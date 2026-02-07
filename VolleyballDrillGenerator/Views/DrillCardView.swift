import SwiftUI

// MARK: - Drill Card View

/// A compact card that summarises a drill: name, skill badge, and equipment.
struct DrillCardView: View {
    let drill: Drill

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Name & skill badge
            HStack {
                Text(drill.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                if let cat = drill.skillCategory {
                    Text(cat.rawValue)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(skillColor(cat), in: Capsule())
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
    }

    private func skillColor(_ cat: SkillCategory) -> Color {
        switch cat {
        case .serving:  return .blue
        case .passing:  return .green
        case .setting:  return .purple
        case .hitting:  return .red
        case .defense:  return .orange
        case .blocking: return .indigo
        }
    }
}
