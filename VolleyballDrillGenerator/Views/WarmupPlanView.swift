import SwiftUI

// MARK: - Warmup Plan View

/// Displays the 10-minute warmup plan with a timer: start, pause, resume, reset, skip section.
struct WarmupPlanView: View {
    @EnvironmentObject var store: DrillStore
    let level: PlayerLevel

    private let totalSeconds = 600 // 10 min
    private let segmentDuration = 120 // 2 min each

    /// Plan is generated once on appear so segment content doesn’t change when the timer updates.
    @State private var plan: WarmupPlan?

    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var lastSegmentIndexForHaptic: Int = -1
    @State private var expandedSegmentIndex: Int? = nil

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

                        if store.practicePlanWarmupLevel != level {
                            Button {
                                store.setWarmupInPlan(level: level)
                            } label: {
                                Label("Add warmup to practice plan", systemImage: "plus.circle.fill")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.orange, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }

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
                                isPast: index < currentSegmentIndex,
                                isExpanded: expandedSegmentIndex == index,
                                onTap: { expandedSegmentIndex = expandedSegmentIndex == index ? nil : index }
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
                let idx = currentSegmentIndex
                if idx != lastSegmentIndexForHaptic {
                    lastSegmentIndexForHaptic = idx
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
    }

    private var timerCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formattedElapsed)
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                Text(" / 10:00")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(elapsedSeconds / 60) minutes \(elapsedSeconds % 60) seconds of 10 minutes")

            if let plan = plan, currentSegmentIndex < plan.segments.count, elapsedSeconds > 0 || isRunning {
                Text(plan.segments[currentSegmentIndex].title)
                    .font(.subheadline)
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
                    .accessibilityHint("Starts the 10-minute warmup timer")
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
                        .accessibilityHint("Pauses the timer")
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
                        .accessibilityHint("Resumes the timer")
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
                    .accessibilityHint("Resets the timer to zero")
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
                .accessibilityHint("Jumps to the next warmup segment")
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
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row: icon, title, status, duration, chevron
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
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                // Steps — visible when section is expanded
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        ForEach(Array(segment.instructions.enumerated()), id: \.offset) { stepIndex, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(stepIndex + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .background(Color.orange, in: Circle())
                                Text(step)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                } else {
                    Text("Tap for steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                }
            }
        }
        .buttonStyle(.plain)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.orange : Color.clear, lineWidth: 3)
        )
        .padding(.horizontal)
        .accessibilityLabel("\(segment.title), \(segment.timeRange). \(isExpanded ? "Steps expanded" : "Double tap to show steps")")
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WarmupPlanView(level: .beginner)
            .environmentObject(DrillStore())
    }
}
