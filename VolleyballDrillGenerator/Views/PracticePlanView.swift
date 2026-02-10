import SwiftUI
import UIKit

// MARK: - Practice Plan View

/// Allows users to review their selected 3-5 drill practice session,
/// reorder drills, add warmup, and share the plan.
struct PracticePlanView: View {
    @EnvironmentObject var store: DrillStore
    @State private var showClearConfirm = false
    @State private var generateLevel: PlayerLevel = .beginner

    var body: some View {
        NavigationView {
            Group {
                if store.practicePlan.isEmpty && store.practicePlanWarmupLevel == nil {
                    emptyState
                } else {
                    planList
                }
            }
            .navigationTitle("Practice Plan")
            .toolbar {
                if !store.practicePlan.isEmpty || store.practicePlanWarmupLevel != nil {
                    EditButton()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.6))
            Text("No Drills in Plan")
                .font(.title3.bold())
            Text("Generate a plan or browse drills and tap + to add up to 5 drills.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 12) {
                Picker("Level", selection: $generateLevel) {
                    ForEach(PlayerLevel.allCases) { level in
                        Text(level.shortLabel).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)

                Button {
                    store.generatePlan(for: generateLevel)
                } label: {
                    Label("Generate a plan", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var planList: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Practice Session")
                            .font(.headline)
                        Text(summaryText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if store.estimatedPlanMinutes > 0 {
                            Text("~\(store.estimatedPlanMinutes) min total")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    Spacer()
                    if store.practicePlan.count >= 3 {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else if store.practicePlan.isEmpty && store.practicePlanWarmupLevel != nil {
                        Text("Add drills")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange, in: Capsule())
                    } else {
                        Text("Add \(3 - store.practicePlan.count) more")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red, in: Capsule())
                    }
                }
            }

            Section("Session") {
                if let level = store.practicePlanWarmupLevel {
                    HStack(spacing: 12) {
                        Text("1")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.orange, in: Circle())
                        NavigationLink(destination: WarmupPlanView(level: level)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("10-min warmup")
                                    .font(.subheadline.bold())
                                Text(level.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.setWarmupInPlan(level: nil)
                        } label: {
                            Label("Remove warmup", systemImage: "trash")
                        }
                    }
                }

                ForEach(Array(store.practicePlan.enumerated()), id: \.element.name) { index, drill in
                    NavigationLink(destination: DrillDetailView(drill: drill)) {
                        HStack(spacing: 12) {
                            Text("\(drillNumber(for: index))")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.orange, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(drill.name)
                                    .font(.subheadline.bold())
                                Text(drill.skill)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onMove { indices, destination in
                    store.practicePlan.move(fromOffsets: indices, toOffset: destination)
                    store.savePracticePlan()
                }
                .onDelete { indices in
                    store.practicePlan.remove(atOffsets: indices)
                    store.savePracticePlan()
                }
            }

            Section {
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("Clear Practice Plan", systemImage: "trash")
                }
                .confirmationDialog("Clear Practice Plan?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                    Button("Clear", role: .destructive) {
                        store.clearPlan()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will remove all drills and the warmup from your plan.")
                }

                Button {
                    let av = UIActivityViewController(
                        activityItems: [planText],
                        applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene }).first,
                       let root = windowScene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                } label: {
                    Label("Share Practice Plan", systemImage: "square.and.arrow.up")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var summaryText: String {
        var parts: [String] = []
        if store.practicePlanWarmupLevel != nil { parts.append("Warmup") }
        parts.append("\(store.practicePlan.count) drill\(store.practicePlan.count == 1 ? "" : "s")")
        return parts.joined(separator: " + ")
    }

    private func drillNumber(for index: Int) -> String {
        let offset = store.practicePlanWarmupLevel != nil ? 1 : 0
        return "\(index + 1 + offset)"
    }

    private var planText: String {
        var text = "Volleyball Practice Plan\n"
        text += String(repeating: "=", count: 30) + "\n\n"
        if let level = store.practicePlanWarmupLevel {
            text += "1. Warmup: 10 min (\(level.rawValue))\n"
            text += "   Use the app's 10-Min Warmup for this level.\n\n"
        }
        for (i, drill) in store.practicePlan.enumerated() {
            let num = store.practicePlanWarmupLevel != nil ? i + 2 : i + 1
            text += "\(num). \(drill.name)\n"
            text += "   Skill: \(drill.skill)\n"
            text += "   Equipment: \(drill.equipment.joined(separator: ", "))\n"
            text += "   \(drill.description.replacingOccurrences(of: "\n", with: "\n   "))\n\n"
        }
        return text
    }
}
