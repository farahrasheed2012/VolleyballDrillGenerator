import SwiftUI

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
                VStack(spacing: 24) {

                    // MARK: Drill of the Day
                    if let dotd = store.drillOfTheDay {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Drill of the Day", systemImage: "star.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.yellow)

                            NavigationLink(destination: DrillDetailView(drill: dotd)) {
                                DrillCardView(drill: dotd)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }

                    Divider().padding(.horizontal)

                    // MARK: Player Level Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Player Level")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 10) {
                            ForEach(PlayerLevel.allCases) { level in
                                LevelChip(level: level,
                                          isSelected: selectedLevel == level) {
                                    withAnimation { selectedLevel = level }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Skill Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select a Skill")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(SkillCategory.allCases) { skill in
                                    SkillChip(skill: skill,
                                              isSelected: selectedSkill == skill) {
                                        withAnimation { selectedSkill = skill }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Drill count for current filters
                    let matchCount = store.drills(for: selectedSkill, level: selectedLevel).count
                    Text("\(matchCount) drill\(matchCount == 1 ? "" : "s") available")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // MARK: Generate Button
                    Button {
                        withAnimation(.spring()) {
                            generatedDrill = store.randomDrill(for: selectedSkill,
                                                               level: selectedLevel)
                            animateDrill = true
                        }
                        // Reset animation flag
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            animateDrill = false
                        }
                    } label: {
                        Label("Generate Drill", systemImage: "shuffle")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                    }
                    .padding(.horizontal)

                    // MARK: Generated Drill Result
                    if let drill = generatedDrill {
                        NavigationLink(destination: DrillDetailView(drill: drill)) {
                            DrillCardView(drill: drill)
                                .scaleEffect(animateDrill ? 1.03 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("Tap Generate to get a random drill!")
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Volleyball Drill Generator")
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
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? level.color : Color(.systemGray5),
                        in: Capsule())
        }
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
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.orange : Color(.systemGray5),
                        in: Capsule())
        }
    }
}
