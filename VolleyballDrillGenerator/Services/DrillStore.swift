import Foundation

// MARK: - Drill Store

/// Loads drills from the bundled JSON file and provides
/// filtering, random selection, and practice-plan persistence.
class DrillStore: ObservableObject {

    // All drills from the JSON database
    @Published var allDrills: [Drill] = []

    /// Non-nil when drill JSON failed to load; UI can show message and retry.
    @Published var loadError: String?

    // The randomly chosen "Drill of the Day"
    @Published var drillOfTheDay: Drill?

    // Current practice plan (selected drills, 3-5)
    @Published var practicePlan: [Drill] = []

    // Optional 10-min warmup as first item in plan (level chosen by user)
    @Published var practicePlanWarmupLevel: PlayerLevel?

    // Favorite drill names (persisted)
    @Published var favoriteDrillNames: Set<String> = []

    // Recently viewed drill names, most recent last (max 10)
    @Published var recentlyViewedDrillNames: [String] = []

    private let planKey = "savedPracticePlan"
    private let warmupPlanKey = "savedPracticePlanWarmup"
    private let favoritesKey = "favoriteDrillNames"
    private let recentlyViewedKey = "recentlyViewedDrillNames"
    private let maxRecentCount = 10

    init() {
        loadDrillsFromBundle()
        pickDrillOfTheDay()
        loadPracticePlan()
        loadWarmupPlan()
        loadFavorites()
        loadRecentlyViewed()
    }

    // MARK: - Loading

    /// Load drills from the bundled volleyball_drills.json. Sets loadError on failure.
    private func loadDrillsFromBundle() {
        loadError = nil
        guard let url = Bundle.main.url(forResource: "volleyball_drills",
                                        withExtension: "json") else {
            loadError = "Drills couldn't be loaded."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Drill].self, from: data)
            allDrills = decoded
        } catch {
            loadError = "Drills couldn't be loaded."
        }
    }

    /// Call after load failure to retry loading the drill database.
    func retryLoadDrills() {
        loadDrillsFromBundle()
        if loadError == nil {
            pickDrillOfTheDay()
            loadPracticePlan()
            loadWarmupPlan()
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
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allDrills.count
        drillOfTheDay = allDrills[index]
    }

    /// Pick a new random drill of the day (e.g. after pull-to-refresh)
    func refreshDrillOfTheDay() {
        guard !allDrills.isEmpty else { return }
        drillOfTheDay = allDrills.randomElement()
    }

    // MARK: - Practice Plan Persistence

    /// Save the current practice plan drill names to UserDefaults. Triggers brief "Plan saved" feedback in UI.
    func savePracticePlan() {
        let names = practicePlan.map(\.name)
        UserDefaults.standard.set(names, forKey: planKey)
        planSavedAt = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.planSavedAt = nil
        }
    }

    /// Load a previously saved practice plan
    private func loadPracticePlan() {
        guard let names = UserDefaults.standard.stringArray(forKey: planKey) else { return }
        practicePlan = names.compactMap { name in
            allDrills.first { $0.name == name }
        }
    }

    private func loadWarmupPlan() {
        guard let raw = UserDefaults.standard.string(forKey: warmupPlanKey),
              let level = PlayerLevel(rawValue: raw) else { return }
        practicePlanWarmupLevel = level
    }

    private func saveWarmupPlan() {
        if let level = practicePlanWarmupLevel {
            UserDefaults.standard.set(level.rawValue, forKey: warmupPlanKey)
        } else {
            UserDefaults.standard.removeObject(forKey: warmupPlanKey)
        }
        planSavedAt = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.planSavedAt = nil
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

    /// Remove all drills from the plan (and warmup)
    func clearPlan() {
        practicePlan.removeAll()
        practicePlanWarmupLevel = nil
        savePracticePlan()
        saveWarmupPlan()
    }

    /// Last time the plan was saved; UI uses this to show "Plan saved" briefly.
    @Published var planSavedAt: Date?

    /// Set or clear warmup as first item in practice plan
    func setWarmupInPlan(level: PlayerLevel?) {
        practicePlanWarmupLevel = level
        saveWarmupPlan()
    }

    /// Estimated total minutes for current plan (warmup + ~7 min per drill)
    var estimatedPlanMinutes: Int {
        let drillMinutes = practicePlan.count * 7
        let warmupMinutes = practicePlanWarmupLevel != nil ? 10 : 0
        return warmupMinutes + drillMinutes
    }

    /// Generate a random plan for the given level: warmup + 4–5 drills across skills (blocking for intermediate).
    func generatePlan(for level: PlayerLevel) {
        var plan: [Drill] = []
        let coreSkills: [SkillCategory] = [.serving, .passing, .setting, .hitting]
        for skill in coreSkills {
            if let drill = randomDrill(for: skill, level: level), !plan.contains(where: { $0.name == drill.name }) {
                plan.append(drill)
            }
        }
        if plan.count < 5 {
            if let e = drills(for: .defense, level: level).randomElement(), !plan.contains(where: { $0.name == e.name }) {
                plan.append(e)
            }
        }
        if plan.count < 5, level == .intermediate {
            if let b = drills(for: .blocking, level: level).randomElement(), !plan.contains(where: { $0.name == b.name }) {
                plan.append(b)
            }
        }
        practicePlan = Array(plan.prefix(5))
        practicePlanWarmupLevel = level
        savePracticePlan()
        saveWarmupPlan()
    }

    // MARK: - Favorites

    private func loadFavorites() {
        if let names = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favoriteDrillNames = Set(names)
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteDrillNames), forKey: favoritesKey)
    }

    func toggleFavorite(_ drill: Drill) {
        if favoriteDrillNames.contains(drill.name) {
            favoriteDrillNames.remove(drill.name)
        } else {
            favoriteDrillNames.insert(drill.name)
        }
        saveFavorites()
    }

    func isFavorite(_ drill: Drill) -> Bool {
        favoriteDrillNames.contains(drill.name)
    }

    var favoriteDrills: [Drill] {
        allDrills.filter { favoriteDrillNames.contains($0.name) }
    }

    // MARK: - Recently Viewed

    private func loadRecentlyViewed() {
        recentlyViewedDrillNames = UserDefaults.standard.stringArray(forKey: recentlyViewedKey) ?? []
    }

    private func saveRecentlyViewed() {
        UserDefaults.standard.set(recentlyViewedDrillNames, forKey: recentlyViewedKey)
    }

    func recordViewed(_ drill: Drill) {
        recentlyViewedDrillNames.removeAll { $0 == drill.name }
        recentlyViewedDrillNames.append(drill.name)
        if recentlyViewedDrillNames.count > maxRecentCount {
            recentlyViewedDrillNames.removeFirst()
        }
        saveRecentlyViewed()
    }

    var recentlyViewedDrills: [Drill] {
        recentlyViewedDrillNames.reversed().compactMap { name in
            allDrills.first { $0.name == name }
        }
    }
}
