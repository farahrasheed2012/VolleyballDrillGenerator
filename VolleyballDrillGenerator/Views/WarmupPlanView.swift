import SwiftUI

// MARK: - Warmup Plan View

/// Displays the 10-minute warmup plan with a timer: start, pause, resume, reset, skip section.
struct WarmupPlanView: View {
    let level: PlayerLevel

    private let totalSeconds = 600 // 10 min
    private let segmentDuration = 120 // 2 min each

    /// Plan is generated once on appear so segment content doesn’t change when the timer updates.
    @State private var plan: WarmupPlan?

    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = false

    private var currentSegmentIndex: Int {
        guard let plan = plan else { return 0 }
        return min(elapsedSeconds / segmentDuration, plan.segments.count - 1)
    }

    private var canSkipSection: Bool {
        guard let plan = plan else { return false }
        return elapsedSeconds < totalSeconds && currentSegmentIndex < plan.segments.count - 1
    }

    private func skipToNextSection() {
        let nextStart = (currentSegmentIndex + 1) * segmentDuration
        elapsedSeconds = min(nextStart, totalSeconds)
        if elapsedSeconds >= totalSeconds {
            isRunning = false
        }
    }

    private var formattedElapsed: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        Group {
            if let plan = plan {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        timerCard

                        HStack(spacing: 8) {
                            Image(systemName: level.icon)
                            Text(level.rawValue)
                                .font(.headline)
                        }
                        .foregroundColor(level.color)
                        .padding(.horizontal)

                        ForEach(Array(plan.segments.enumerated()), id: \.element.id) { index, segment in
                            WarmupSegmentCard(
                                segment: segment,
                                isActive: index == currentSegmentIndex,
                                isPast: index < currentSegmentIndex
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            } else {
                ProgressView("Loading warmup…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("10-Min Warmup")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if plan == nil {
                plan = WarmupPlan.plan(for: level)
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning && elapsedSeconds < totalSeconds {
                elapsedSeconds += 1
                if elapsedSeconds >= totalSeconds {
                    isRunning = false
                }
            }
        }
    }

    private var timerCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formattedElapsed)
                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                Text(" / 10:00")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: Double(elapsedSeconds), total: Double(totalSeconds))
                .tint(.orange)
                .scaleEffect(y: 1.2)

            // Start / Pause / Resume / Reset
            HStack(spacing: 12) {
                if elapsedSeconds == 0 && !isRunning {
                    Button {
                        isRunning = true
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                } else {
                    if isRunning {
                        Button {
                            isRunning = false
                        } label: {
                            Label("Pause", systemImage: "pause.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            isRunning = true
                        } label: {
                            Label("Resume", systemImage: "play.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        isRunning = false
                        elapsedSeconds = 0
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Skip section (only when there is a next section)
            if canSkipSection {
                Button(action: skipToNextSection) {
                    Label("Skip to next section", systemImage: "forward.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Warmup Segment Card

private struct WarmupSegmentCard: View {
    let segment: WarmupPlanSegment
    let isActive: Bool
    let isPast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: segment.icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .orange)
                    .frame(width: 32, alignment: .center)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(segment.title)
                            .font(.headline)
                        if isActive {
                            Text("Now")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange, in: Capsule())
                        } else if isPast {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    Text(segment.timeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(segment.durationMinutes) min")
                    .font(.subheadline.bold())
                    .foregroundColor(isActive ? .orange : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isActive ? Color.orange.opacity(0.2) : Color.orange, in: Capsule())
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
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.orange : Color.clear, lineWidth: 3)
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WarmupPlanView(level: .beginner)
    }
}
