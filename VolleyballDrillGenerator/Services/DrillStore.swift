import Foundation

// MARK: - Drill Store

/// Loads drills from the bundled JSON file and provides
/// filtering, random selection, and practice-plan persistence.
class DrillStore: ObservableObject {

    // All drills from the JSON database
    @Published var allDrills: [Drill] = []

    // The randomly chosen "Drill of the Day"
    @Published var drillOfTheDay: Drill?

    // Current practice plan (selected drills, 3-5)
    @Published var practicePlan: [Drill] = []

    init() {
        loadDrills()
        pickDrillOfTheDay()
        loadPracticePlan()
    }

    // MARK: - Loading

    /// Load drills from the bundled volleyball_drills.json
    private func loadDrills() {
        guard let url = Bundle.main.url(forResource: "volleyball_drills",
                                        withExtension: "json") else {
            print("volleyball_drills.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Drill].self, from: data)
            allDrills = decoded
        } catch {
            print("Failed to decode drills: \(error)")
        }
    }

    // MARK: - Filtering

    /// Return all drills matching a given skill category
    func drills(for skill: SkillCategory) -> [Drill] {
        allDrills.filter { $0.skill == skill.rawValue }
    }

    /// Return all drills matching both a skill and a player level
    func drills(for skill: SkillCategory, level: PlayerLevel) -> [Drill] {
        allDrills.filter { $0.skill == skill.rawValue && $0.level == level.rawValue }
    }

    /// Return a random drill for the given skill
    func randomDrill(for skill: SkillCategory) -> Drill? {
        drills(for: skill).randomElement()
    }

    /// Return a random drill for the given skill AND player level
    func randomDrill(for skill: SkillCategory, level: PlayerLevel) -> Drill? {
        drills(for: skill, level: level).randomElement()
    }

    // MARK: - Drill of the Day

    /// Pick one random drill per calendar day (stable for the day)
    private func pickDrillOfTheDay() {
        guard !allDrills.isEmpty else { return }

        // Use the day-of-year as a stable seed so the drill
        // stays the same throughout the day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allDrills.count
        drillOfTheDay = allDrills[index]
    }

    // MARK: - Practice Plan Persistence

    private let planKey = "savedPracticePlan"

    /// Save the current practice plan drill names to UserDefaults
    func savePracticePlan() {
        let names = practicePlan.map(\.name)
        UserDefaults.standard.set(names, forKey: planKey)
    }

    /// Load a previously saved practice plan
    private func loadPracticePlan() {
        guard let names = UserDefaults.standard.stringArray(forKey: planKey) else { return }
        practicePlan = names.compactMap { name in
            allDrills.first { $0.name == name }
        }
    }

    /// Toggle a drill in/out of the practice plan (max 5)
    func toggleInPlan(_ drill: Drill) {
        if let idx = practicePlan.firstIndex(of: drill) {
            practicePlan.remove(at: idx)
        } else if practicePlan.count < 5 {
            practicePlan.append(drill)
        }
        savePracticePlan()
    }

    /// Whether a drill is currently in the practice plan
    func isInPlan(_ drill: Drill) -> Bool {
        practicePlan.contains(drill)
    }

    /// Remove all drills from the plan
    func clearPlan() {
        practicePlan.removeAll()
        savePracticePlan()
    }
}
