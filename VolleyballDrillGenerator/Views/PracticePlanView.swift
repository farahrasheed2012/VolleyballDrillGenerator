import SwiftUI
import UIKit

// MARK: - Practice Plan View

/// Allows users to review their selected 3-5 drill practice session,
/// reorder drills, and share the plan.
struct PracticePlanView: View {
    @EnvironmentObject var store: DrillStore

    var body: some View {
        NavigationView {
            Group {
                if store.practicePlan.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.orange.opacity(0.6))
                        Text("No Drills in Plan")
                            .font(.title3.bold())
                        Text("Browse drills and tap + to add up to 5 drills\nfor your practice session.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        // Plan summary header
                        Section {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Practice Session")
                                        .font(.headline)
                                    Text("\(store.practicePlan.count) drill\(store.practicePlan.count == 1 ? "" : "s") selected")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // Minimum check
                                if store.practicePlan.count < 3 {
                                    Text("Add \(3 - store.practicePlan.count) more")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.red, in: Capsule())
                                } else {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                        }

                        // Drill list with numbers
                        Section("Drill Order") {
                            ForEach(Array(store.practicePlan.enumerated()), id: \.element.name) { index, drill in
                                NavigationLink(destination: DrillDetailView(drill: drill)) {
                                    HStack(spacing: 12) {
                                        // Order number circle
                                        Text("\(index + 1)")
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

                        // Share / Clear buttons
                        Section {
                            Button(role: .destructive) {
                                store.clearPlan()
                            } label: {
                                Label("Clear Practice Plan", systemImage: "trash")
                            }

                            // Share as text
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
            }
            .navigationTitle("Practice Plan")
            .toolbar {
                if !store.practicePlan.isEmpty {
                    EditButton()
                }
            }
        }
    }

    /// Plain-text version of the plan for sharing
    private var planText: String {
        var text = "Volleyball Practice Plan\n"
        text += String(repeating: "=", count: 30) + "\n\n"
        for (i, drill) in store.practicePlan.enumerated() {
            text += "Drill \(i + 1): \(drill.name)\n"
            text += "Skill: \(drill.skill)\n"
            text += "Equipment: \(drill.equipment.joined(separator: ", "))\n"
            text += "\(drill.description)\n\n"
        }
        return text
    }
}
