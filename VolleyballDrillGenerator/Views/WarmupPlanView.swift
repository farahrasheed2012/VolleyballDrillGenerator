import SwiftUI

// MARK: - Warmup Plan View

/// Displays the 10-minute warmup plan for the selected level with segments:
/// Stretching, Hands & Arms, Legs, Movement, Ball.
struct WarmupPlanView: View {
    let level: PlayerLevel
    private var plan: WarmupPlan { WarmupPlan.plan(for: level) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("10 minutes total")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: level.icon)
                        Text(level.rawValue)
                            .font(.headline)
                    }
                    .foregroundColor(level.color)
                }
                .padding(.horizontal)

                // Segments
                ForEach(plan.segments) { segment in
                    WarmupSegmentCard(segment: segment)
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("10-Min Warmup")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Warmup Segment Card

private struct WarmupSegmentCard: View {
    let segment: WarmupPlanSegment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: segment.icon)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 32, alignment: .center)
                VStack(alignment: .leading, spacing: 2) {
                    Text(segment.title)
                        .font(.headline)
                    Text(segment.timeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(segment.durationMinutes) min")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange, in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(segment.instructions.enumerated()), id: \.offset) { _, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.orange)
                        Text(step)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WarmupPlanView(level: .beginner)
    }
}
