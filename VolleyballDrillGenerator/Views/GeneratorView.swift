import SwiftUI
import UIKit

// MARK: - Generator View

/// Main generator screen: level picker, skill picker, generate button,
/// random drill display, and a "Drill of the Day" card at the top.
struct GeneratorView: View {
    @EnvironmentObject var store: DrillStore
    @State private var selectedSkill: SkillCategory = .serving
    @State private var selectedLevel: PlayerLevel = .newToVolleyball
    @State private var generatedDrill: Drill?
    @State private var animateDrill = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: Drill of the Day
                    if let dotd = store.drillOfTheDay {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Drill of the Day", systemImage: "star.fill")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)

                            NavigationLink(destination: DrillDetailView(drill: dotd)) {
                                DrillCardView(drill: dotd)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Drill of the Day, \(dotd.name)")
                    }

                    // MARK: Player Level Picker
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Player Level")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 4)

                        HStack(spacing: 10) {
                            ForEach(PlayerLevel.allCases) { level in
                                LevelChip(level: level,
                                          isSelected: selectedLevel == level) {
                                    withAnimation { selectedLevel = level }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Skill Picker
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Select a Skill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(SkillCategory.allCases) { skill in
                                    SkillChip(skill: skill,
                                              isSelected: selectedSkill == skill) {
                                        withAnimation { selectedSkill = skill }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Drill count for current filters
                    let matchCount = store.drills(for: selectedSkill, level: selectedLevel).count
                    Text("\(matchCount) drill\(matchCount == 1 ? "" : "s") available")
                        .font(.footnote)
                        .foregroundColor(Color(.tertiaryLabel))
                        .padding(.horizontal, 20)

                    // MARK: 10-Minute Warmup Plan (when Warmup selected)
                    if selectedSkill == .warmup {
                        NavigationLink(destination: WarmupPlanView(level: selectedLevel)) {
                            HStack(spacing: 16) {
                                Image(systemName: "clock.badge.checkmark")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 36, alignment: .center)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("10-Minute Warmup Plan")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text("Stretching, hands & arms, legs, movement, ball")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            .padding(20)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }

                    // MARK: Generate Button
                    Button {
                        generatedDrill = store.randomDrill(for: selectedSkill,
                                                           level: selectedLevel)
                        let useMotion = !UIAccessibility.isReduceMotionEnabled
                        if useMotion {
                            withAnimation(.spring()) { animateDrill = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                animateDrill = false
                            }
                        }
                    } label: {
                        Label("Generate Drill", systemImage: "shuffle")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.regular)
                    .padding(.horizontal, 20)

                    // MARK: Generated Drill Result
                    if let drill = generatedDrill {
                        VStack(alignment: .leading, spacing: 16) {
                            NavigationLink(destination: DrillDetailView(drill: drill)) {
                                DrillCardView(drill: drill)
                                    .scaleEffect((animateDrill && !UIAccessibility.isReduceMotionEnabled) ? 1.02 : 1.0)
                            }
                            .buttonStyle(.plain)

                            Button {
                                store.toggleInPlan(drill)
                            } label: {
                                Label(
                                    store.isInPlan(drill) ? "Remove from plan" : "Add to plan",
                                    systemImage: store.isInPlan(drill) ? "minus.circle.fill" : "plus.circle.fill"
                                )
                                .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.bordered)
                            .tint(store.isInPlan(drill) ? .red : .orange)
                            .disabled(store.practicePlan.count >= 5 && !store.isInPlan(drill))
                            .opacity(store.practicePlan.count >= 5 && !store.isInPlan(drill) ? 0.6 : 1)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    } else {
                        Text("Tap Generate to get a random drill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 36)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Generator")
            .background(Color(.systemGroupedBackground))
            .refreshable {
                store.refreshDrillOfTheDay()
            }
        }
    }
}

// MARK: - Level Chip

/// A selectable chip for each player level
struct LevelChip: View {
    let level: PlayerLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: level.icon)
                    .font(.caption)
                Text(level.shortLabel)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? level.color : Color(.tertiarySystemFill),
                        in: Capsule())
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}

// MARK: - Skill Chip

/// A selectable chip for each skill category
struct SkillChip: View {
    let skill: SkillCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: skill.icon)
                    .font(.subheadline)
                Text(skill.rawValue)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.orange : Color(.tertiarySystemFill),
                        in: Capsule())
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}
